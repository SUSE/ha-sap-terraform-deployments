# Global variables

variable "project" {
  type = "string"
}

variable "gcp_credentials_file" {
  type = "string"
}

variable "public_key_location" {
  type = "string"
}

variable "private_key_location" {
  type = "string"
}

variable "machine_type" {
  type    = "string"
  default = "n1-highmem-8"
}

variable "iscsi_server_boot_image" {
  type    = "string"
  default = "suse-byos-cloud/sles-15-sap-byos"
}

variable "machine_type_iscsi_server" {
  type    = "string"
  default = "custom-1-2048"
}

variable "region" {
  type = "string"
}

variable "sles4sap_boot_image" {
  type = "string"
  default = "suse-byos-cloud/sles-15-sap-byos"
}

variable "storage_url" {
  type    = "string"
  default = "https://storage.googleapis.com"
}

variable "ninstances" {
  type    = "string"
  default = "2"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = "string"
  default     = "hana"
}

variable "init_type" {
  type    = "string"
  default = "all"
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

# HANA variables

variable "sap_hana_deployment_bucket" {
  description = "GCP storage bucket that contains the SAP HANA installation files"
  type        = "string"
}

variable "hana_inst_folder" {
  type = "string"
}

variable "hana_disk_device" {
  description = "device where to install HANA"
  type        = "string"
}

variable "hana_inst_disk_device" {
  description = "device where to download HANA"
  type        = "string"
}

variable "hana_fstype" {
  description = "Filesystem type to use for HANA"
  type        = "string"
  default     = "xfs"
}

# SUSE subscription variables

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

# Repository url used to install install HA/SAP deployment packages"
# The latest RPM packages can be found at:
# https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/{YOUR OS VERSION}
# Contains the salt formulas rpm packages.
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install install HA/SAP deployment packages"
  type        = "string"
}

# Network variables
# Pay attention to set ip address according to the cidr range

variable "ip_cidr_range" {
  description = "internal IPv4 range"
}

variable "iscsi_ip" {
  description = "IP for iSCSI server"
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = "list"
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
  type        = "string"
  default     = "false"
}
