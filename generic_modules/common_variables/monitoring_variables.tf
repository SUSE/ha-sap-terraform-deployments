variable "monitoring_hana_targets" {
  description = "IPs of HANA hosts you want to monitor."
  type        = list(string)
  default     = []
}

variable "monitoring_hana_targets_ha" {
  description = "IPs of HANA HA hosts you want to monitor."
  type        = list(string)
  default     = []
}

variable "monitoring_hana_targets_vip" {
  description = "VIPs of HANA DBs you want to monitor."
  type        = list(string)
  default     = []
}

variable "monitoring_drbd_targets" {
  description = "IPs of DRBD hosts you want to monitor"
  type        = list(string)
  default     = []
}

variable "monitoring_drbd_targets_ha" {
  description = "IPs of DRBD HA hosts you want to monitor"
  type        = list(string)
  default     = []
}

variable "monitoring_drbd_targets_vip" {
  description = "VIPs of DRBD NFS services you want to monitor"
  type        = list(string)
  default     = []
}

variable "monitoring_netweaver_targets" {
  description = "IPs of Netweaver hosts you want to monitor."
  type        = list(string)
  default     = []
}

variable "monitoring_netweaver_targets_ha" {
  description = "IPs of Netweaver HA hosts you want to monitor."
  type        = list(string)
  default     = []
}

variable "monitoring_netweaver_targets_vip" {
  description = "VIPs of Netweaver Instances you want to monitor."
  type        = list(string)
  default     = []
}
