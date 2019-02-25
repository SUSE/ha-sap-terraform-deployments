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

# Map used for suse-sles-sap-15-byos-v20180816-hvm-ssd-x86_64
# SLES4SAP 15 in eu-central-1: ami-024f50fdc1f2f5603
# Used for iscsi server

variable "iscsi_srv" {
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

variable "init_type" {
  type    = "string"
  default = "all"
}

variable "hana_inst_master" {
  type = "string"
}

variable "hana_inst_folder" {
  type = "string"
}

variable "hana_disk_device" {
  description = "device where to install HANA"
  type        = "string"
}

variable "iscsidev" {
  description = "device iscsi for iscsi server"
  type        = "string"
}

variable "cluster_ssh_pub" {
  description = "path for the public key needed by the cluster"
  type        = "string"
}

variable "cluster_ssh_key" {
  description = "path for the private key needed by the cluster"
  type        = "string"
}

variable "reg_code" {
  description = "If informed, register the product using SUSEConnect"
  type        = "string"
  default     = ""
}

variable "reg_email" {
  description = "Email used for the registration"
  default     = ""
}

# The module format must follow SUSEConnect convention:
# <module_name>/<product_version>/<architecture>
# Example: Suggested modules for SLES for SAP 15
# - sle-module-basesystem/15/x86_64
# - sle-module-desktop-applications/15/x86_64
# - sle-module-server-applications/15/x86_64
# - sle-ha/15/x86_64 (Need the same regcode as SLES for SAP)
# - sle-module-sap-applications/15/x86_64

variable "reg_additional_modules" {
  description = "Map of the modules to be registered. Module name = Regcode, when needed."
  type        = "map"
  default     = {}
}

variable "additional_repos" {
  description = "extra repositories used for installation {label = url}"
  default     = {}
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  default     = []
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = "list"
}

# Specific QA variables

variable "qa_mode" {
  description = "define qa mode (Disable extra packages outside images)"
  type        = "string"
  default     = "false"
}

variable "qa_reg_code" {
  description = "registrating code to install the salt minion"
  type        = "string"
  default     = "empty"
}
