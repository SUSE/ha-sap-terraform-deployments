# Launch SLES-HAE of SLES4SAP cluster nodes

# Map used for suse-sles-sap-15-byos-v20180816-hvm-ssd-x86_64
# SLES4SAP 15 in eu-central-1: ami-024f50fdc1f2f5603
# Used for cluster nodes

variable "sles4sap" {
  type = "map"

  default = {
    "us-east-1"    = "ami-027447d2b7312df2d"
    "us-east-2"    = "ami-099a51d3b131f3ce2"
    "us-west-1"    = "ami-0f213357578720889"
    "us-west-2"    = "ami-0fc86417df3e0f6d4"
    "ca-central-1" = "ami-0811b93a30ab570f7"
    "eu-central-1" = "ami-024f50fdc1f2f5603"
    "eu-west-1"    = "ami-0ca96dfbaf35b0c31"
    "eu-west-2"    = "ami-00189dbab3fd43af2"
    "eu-west-3"    = "ami-00e70e3421f053648"
  }
}

# Map used for suse-sles-sap-12-sp4-byos-v20181212-hvm-ssd-x86_64
# SLES4SAP 12SP4 in eu-central-1: ami-027ab92ac76584bfd
# Used for iscsi server

variable "iscsi_srv" {
  type = "map"

  default = {
    "us-east-1"    = "ami-00ec2c9db6d48cd44"
    "us-east-2"    = "ami-00ec2c9db6d48cd44"
    "us-west-1"    = "ami-0df4bc22c34ae1b79"
    "us-west-2"    = "ami-0941337aabe54ea2c"
    "ca-central-1" = "ami-0d4b452ab1f2f86d3"
    "eu-central-1" = "ami-027ab92ac76584bfd"
    "eu-west-1"    = "ami-0b0d07bd990ccf8c8"
    "eu-west-2"    = "ami-07e9d18e2d5b1e5ce"
    "eu-west-3"    = "ami-0f916db5a97a370f0"
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
