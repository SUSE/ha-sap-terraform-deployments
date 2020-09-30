variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

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

variable "os_image" {
  description = "sles4sap image used to create this module machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
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

variable "admin_user" {
  type    = string
  default = "azadmin"
}

variable "bastion_enabled" {
  description = "Use a bastion machine to create the ssh connections"
  type        = bool
  default     = true
}

variable "bastion_host" {
  description = "Bastion host address"
  type        = string
  default     = ""
}

variable "bastion_private_key" {
  description = "Path to a SSH private key used to connect to the bastion. It must be provided if bastion is enabled"
  type        = string
  default     = ""
}

variable "hana_targets" {
  description = "IPs of HANA hosts you want to monitor; the last one is assumed to be the virtual IP of the active HA instance."
  type        = list(string)
}

variable "drbd_targets" {
  description = "IPs of DRBD hosts you want to monitor"
  type        = list(string)
  default     = []
}

variable "netweaver_targets" {
  description = "IPs of Netweaver hosts you want to monitor; the first two are assumed to be the virtual IPs of the HA instances."
  type        = list(string)
  default     = []
}
