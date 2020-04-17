variable "az_region" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type = string
}

variable "sec_group_id" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "network_subnet_id" {
  type = string
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

variable "storage_account" {
  type = string
}

variable "monitoring_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "monitoring_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "monitoring_public_sku" {
  type    = string
  default = "15"
}

variable "monitoring_public_version" {
  type    = string
  default = "latest"
}

variable "monitoring_uri" {
  type    = string
  default = ""
}

variable "monitoring_srv_ip" {
  description = "monitoring server address"
  type        = string
  default     = ""
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "admin_user" {
  type    = string
  default = "azadmin"
}

variable "public_key_location" {
  type = string
}

variable "private_key_location" {
  type = string
}

variable "reg_code" {
  description = "If informed, register the product using SUSEConnect"
  default     = ""
}

variable "reg_email" {
  description = "Email used for the registration"
  default     = ""
}

variable "reg_additional_modules" {
  description = "Map of the modules to be registered. Module name = Regcode, when needed."
  type        = map(string)
  default     = {}
}

variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages"
  type        = string
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  default     = []
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  type        = bool
  default     = false
}

variable "drbd_enabled" {
  description = "enable the DRBD cluster for nfs"
  type        = bool
  default     = false
}

variable "drbd_ips" {
  description = "ip addresses to set to the drbd cluster nodes"
  type        = list(string)
  default     = []
}

variable "netweaver_enabled" {
  description = "enable SAP Netweaver cluster deployment"
  type        = bool
  default     = false
}

variable "netweaver_ips" {
  description = "ip addresses to set to the netweaver cluster nodes"
  type        = list(string)
  default     = []
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}
