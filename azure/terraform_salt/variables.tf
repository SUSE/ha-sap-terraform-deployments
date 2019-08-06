# Launch SLES-HAE of SLES4SAP cluster nodes

# Variables for type of instances to use and number of cluster nodes
# Use with: terraform apply -var instancetype=Small -var ninstances=2

variable "instancetype" {
  type    = "string"
  default = "Standard_E4s_v3"
}

# For reference:
# Standard_B1ms has 1 VCPU, 2GiB RAM, 1 NIC, 2 data disks and 4GiB SSD
# Standard_D2s_v3 has 2 VCPU, 8GiB RAM, 2 NICs, 4 data disks and 16GiB SSD disk
# Standard_D8s_v3 has 8 VCPU, 32GiB RAM, 2 NICs, 16 data disks and 64GiB SSD disk
# Standard_E4s_v3 has 4 VCPU, 32GiB RAM, 2 NICs, 64GiB SSD disk
# Standard_M32ts has 32 VCPU, 192GiB RAM, 1000 GiB SSD

variable "ninstances" {
  type    = "string"
  default = "2"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = "string"
  default     = "hana"
}

# Variable for default region where to deploy resources

variable "az_region" {
  type    = "string"
  default = "westeurope"
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

variable "hana_fstype" {
  description = "Filesystem type to use for HANA"
  type        = "string"
  default     = "xfs"
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

# Repository url used to install install HA/SAP deployment packages"
# The latest RPM packages can be found at:
# https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/{YOUR OS VERSION}
# Contains the salt formulas rpm packages.
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install install HA/SAP deployment packages"
  type        = "string"
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  default     = false
}

# Specific QA variables

variable "qa_mode" {
  description = "define qa mode (Disable extra packages outside images)"
  default     = false
}
