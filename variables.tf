variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cidr_block" {
  description = "IPv4 CIDR to assign to the VPC - (65.534 hosts)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks to use for the private subnets - (8.192 hosts per block)"
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks to use for the public subnets - (8.192 hosts per block)"
  type        = list(string)
  default     = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
}

variable "enable_dns_support" {
  description = "Support DNS"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS Hostname"
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "Instance Tenancy"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Mapping of tags"
  type        = map(string)
  default = {
    "Owner" : "scc",
    "Project" : "vpc",
    "Terraform" : "true"
  }
}