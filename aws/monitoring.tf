variable "monitoring_srv_ip" {
  description = "monitoring server address. Must be in 10.0.0.0/24 subnet"
  type        = string
  default     = ""
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}
