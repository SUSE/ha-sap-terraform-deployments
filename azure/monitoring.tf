variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

variable "monitoring_srv_ip" {
  description = "monitoring server address"
  type        = string
}

variable "devel_mode" {
  description = "whether or not to install HA/SAP packages from ha_sap_deployment_repo"
  default     = false
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  default     = true
}
