# Configure the AWS Provider
provider "aws" {
  version = "~> 1.29"
  region  = "${var.aws_region}"
}

provider "template" {
  version = "~> 1.0"
}
