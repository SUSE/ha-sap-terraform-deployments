variable "monitoring_count" {
  description = "number of hosts like this one"
  default     = 1
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

variable "monitored_hosts" {
  description = "IPs of hosts you want to monitor"
  type        = list(string)
}

variable "monitoring_srv_ip" {
  description = "monitoring server address"
  type        = string
}
