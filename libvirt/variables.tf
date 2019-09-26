variable "qemu_uri" {
  description = "URI to connect with the qemu-service."
  default     = "qemu:///system"
}

variable "base_image" {
  description = "Image of the sap hana nodes"
  type        = string
}

variable "iprange" {
  description = "IP range of the isolated network"
  default     = "192.168.106.0/24"
}

variable "sap_inst_media" {
  description = "URL of the NFS share where the SAP software installer is stored. This media shall be mounted in /root/sap_inst"
  type        = string
}

variable "hana_inst_folder" {
  description = "Folder where SAP HANA installation files are stored"
  type        = string
  default     = "/root/sap_inst"
}

variable "hana_fstype" {
  description = "Filesystem type to use for HANA"
  type        = string
  default     = "xfs"
}

variable "host_ips" {
  description = "IP addresses of the nodes"
  type        = list(string)
  default     = ["192.168.106.15", "192.168.106.16"]
}

variable "shared_storage_type" {
  description = "used shared storage type for fencing (sbd). Available options: iscsi, shared-disk."
  type        = string
  default     = "iscsi"
}

variable "iscsi_image" {
  description = "iscsi server base image (only used if shared_storage_type is iscsi)"
  type        = string
  default     = ""
}

variable "iscsi_srv_ip" {
  description = "iscsi server address (only used if shared_storage_type is iscsi)"
  type        = string
  default     = "192.168.106.17"
}

variable "monitoring_srv_ip" {
  description = "monitoring server address"
  type        = string
}

variable "reg_code" {
  description = "If informed, register the product using SUSEConnect"
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
  type        = map(string)
  default     = {}
}

# Repository url used to install HA/SAP deployment packages"
# The latest RPM packages can be found at:
# https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/{YOUR OS VERSION}
# Contains the salt formulas rpm packages.
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages"
  type        = "string"
}

variable "devel_mode" {
  description = "whether or not to install HA/SAP packages from ha_sap_deployment_repo"
  default     = false
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

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  default     = false
}

variable "storage_pool" {
  description = "libvirt storage pool name for VM disks"
  default     = "default"
}

variable "qa_mode" {
  description = "define qa mode (Disable extra packages outside images)"
  default     = false
}

variable "hwcct" {
  description = "Execute HANA Hardware Configuration Check Tool to bench filesystems"
  type        = bool
  default     = false
}
