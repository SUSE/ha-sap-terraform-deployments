terraform {
  required_version = ">= 1.1.0"
  required_providers {
    # Configure the Azure Provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
