variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

variable "compute_zones" {
  description = "gcp compute zones data"
  type        = list(string)
}

variable "network_subnet_name" {
  description = "Subnet name to attach the network interface of the nodes"
  type        = string
}

variable "os_image" {
  description = "Image used to create the machine"
  type        = string
}

variable "monitoring_srv_ip" {
  description = "Monitoring server address"
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

variable "on_destroy_dependencies" {
  description = "Resources objects need in the on_destroy script (everything that allows ssh connection)"
  type        = any
  default     = []
}
