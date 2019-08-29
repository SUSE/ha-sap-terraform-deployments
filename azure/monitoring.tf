variable "monitoring_count" {
  description = "number of hosts like this one"
  default     = 1
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}


variable "monitored_services" {
  description = "HOST:PORT of service you want to monitor, it can contain same host with different ports number (diff services)"
  type        = list(string)
}

variable "monitoring_srv_ip" {
  description = "monitoring server address"
  type        = string
}
