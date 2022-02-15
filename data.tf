data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name
  azs            = slice(data.aws_availability_zones.current.names, 0, length(var.public_subnet_cidrs))
}