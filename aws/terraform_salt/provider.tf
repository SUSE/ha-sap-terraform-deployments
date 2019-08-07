# Configure the AWS Provider
provider "aws" {
  version = "~> 2.7"
  region  = var.aws_region
}

provider "template" {
  version = "~> 2.1"
}

