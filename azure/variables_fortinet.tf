variable "fortinet_enabled" {
  description = "Create FortiGate AP ELB/ILB and FortiADC HA deployments"
  type        = bool
  default     = false
}

variable "snet_ids" {
  type    = list(string)
  default = []
}

variable "snet_address_ranges" {
  type    = list(string)
  default = []
}