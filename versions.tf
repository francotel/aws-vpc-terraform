terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.70.0"
    }
  }
}

# Lista de versiones de hashicorp aws https://registry.terraform.io/providers/hashicorp/aws/latest