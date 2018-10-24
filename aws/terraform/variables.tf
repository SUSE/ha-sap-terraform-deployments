# Launch SLES-HAE of SLES4SAP cluster nodes

# Map for suse-sles-sap-12-sp3-byos-v20180706-hvm-ssd-x86_64
# SLES 12SP3 in eu-central-1: ami-2cffc5c7

variable "sles4sap" {
  type = "map"

  default = {
    "us-east-1"    = "ami-b1daf5ce"
    "us-east-2"    = "ami-bf8db5da"
    "us-west-1"    = "ami-9f08e8fc"
    "us-west-2"    = "ami-2c693f54"
    "ca-central-1" = "ami-890f8ded"
    "eu-central-1" = "ami-6da59f86"
    "eu-west-1"    = "ami-a07b6d4a"
    "eu-west-2"    = "ami-f40ae293"
    "eu-west-3"    = "ami-b8cb7bc5"
  }
}

# Variables for type of instances to use and number of cluster nodes
# Use with: terraform apply -var instancetype=t2.micro -var ninstances=2

variable "instancetype" {
  type    = "string"
  default = "t2.micro"
}

variable "ninstances" {
  type    = "string"
  default = "2"
}

variable "aws_region" {
  type = "string"
}

variable "public_key" {
  type = "string"
}

variable "private_key_location" {
  type = "string"
}

variable "aws_credentials" {
  type    = "string"
  default = "~/.aws/credentials"
}

variable "init-type" {
  type    = "string"
  default = "all"
}

variable "hana_inst_master" {
  type = "string"
}

