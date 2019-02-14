variable "qemu_uri" {
  description = "URI to connect with the qemu-service."
  default     = "qemu:///system"
}

variable "base_image" {
  description = "Image of the sap hana nodes"
  type        = "string"
}

variable "iprange" {
  description = "IP range of the isolated network"
  default     = "192.168.106.0/24"
}

variable "name_prefix" {
  description = "Prefix of the deployment VM, network and disks"
  default     = "hanatest"
}

variable "sap_inst_media" {
  description = "URL of the NFS share where the SAP software installer is stored. This media shall be mounted in /root/sap_inst"
  type        = "string"
}

variable "host_ips" {
  description = "IP addresses of the nodes"
  default     = ["192.168.106.15", "192.168.106.16"]
}

variable "ntp_server" {
  description = "ntp server address. Let empty to not setup any ntp server"
  default     = ""
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
  type        = "map"
  default     = {}
}

variable "additional_repos" {
  description = "Map of the repositories to add to the images. Repo name = url"
  type        = "map"
  default     = {}
}
