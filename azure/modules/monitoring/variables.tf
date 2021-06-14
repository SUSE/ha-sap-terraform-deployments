variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "bastion_host" {
  description = "Bastion host address"
  type        = string
  default     = ""
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

variable "hana_targets" {
  description = "IPs of HANA hosts you want to monitor."
  type        = list(string)
}

variable "hana_targets_ha" {
  description = "IPs of HANA HA hosts you want to monitor."
  type        = list(string)
}

variable "hana_targets_vip" {
  description = "VIPs of HANA DBs you want to monitor."
  type        = list(string)
}

variable "drbd_targets" {
  description = "IPs of DRBD hosts you want to monitor"
  type        = list(string)
  default     = []
}

variable "drbd_targets_ha" {
  description = "IPs of DRBD HA hosts you want to monitor"
  type        = list(string)
  default     = []
}

variable "drbd_targets_vip" {
  description = "VIPs of DRBD NFS services you want to monitor"
  type        = list(string)
  default     = []
}

variable "netweaver_targets" {
  description = "IPs of Netweaver hosts you want to monitor."
  type        = list(string)
  default     = []
}

variable "netweaver_targets_ha" {
  description = "IPs of Netweaver HA hosts you want to monitor."
  type        = list(string)
  default     = []
}

variable "netweaver_targets_vip" {
  description = "VIPs of Netweaver Instances you want to monitor."
  type        = list(string)
  default     = []
}
