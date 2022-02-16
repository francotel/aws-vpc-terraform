#######################################################
#                        VPC                          #
#######################################################
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy     = var.instance_tenancy

  tags = merge(
    {
      "Name" = "vpc-tf",
    },
    var.tags
  )
}

resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route = []

  tags = merge(
    {
      "Name" = "rtb-main-tf",
    },
    var.tags
  )
}

# [PCI.EC2.2] VPC default security group should prohibit inbound and outbound traffic
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    {
      "Name" = "sg-vpc-default-tf",
    },
    var.tags
  )
}

## AWS VPC modify SG custom for PCI
resource "aws_security_group" "sg_vpc_custom" {
  name        = "vpc-sg-custom-tf"
  description = "security group for vpc custom"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "vpc-sg-custom-tf"
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id
  subnet_ids = flatten([
      aws_subnet.private.*.id,
      aws_subnet.public.*.id])

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = merge(
    {
      "Name" = "nacl-vpc-default-tf",
    },
    var.tags
  )
}

#######################################################
#                  Internet Gateway                   #
#######################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      "Name" = "igw-tf",
    },
    var.tags
  )
}

#######################################################
#                    Subnet Public                    #
#######################################################
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(local.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = "subnet-public-${count.index + 1}-tf",
    },
    var.tags
  )
}

#######################################################
#                    Subnet Private                   #
#######################################################
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = element(local.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    {
      "Name" = "subnet-private-${count.index + 1}-tf",
    },
    var.tags
  )
}

#######################################################
#                    Elastic IP                       #
#######################################################
resource "aws_eip" "eip_ngw" {
  count = length(var.public_subnet_cidrs)
  vpc   = true

  tags = merge(
    {
      "Name" = "eip-${count.index + 1}-tf",
    },
    var.tags
  )
}

#######################################################
#                    Nat Gateway                      #
#######################################################
resource "aws_nat_gateway" "ngw" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = element(aws_eip.eip_ngw.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    {
      "Name" = "ngw-${count.index + 1}-tf",
    },
    var.tags
  )
}

#######################################################
#                   Private routes                    #
#######################################################
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
  }

  tags = merge(
    {
      "Name" = "rtb-private-${count.index + 1}-tf",
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[count.index].id
  #route_table_id = element(aws_route_table.private.*.id, count.index)
}

#######################################################
#                   Publiс routes                     #
#######################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      "Name" = "rtb-public-tf",
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}