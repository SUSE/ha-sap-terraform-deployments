variable "fortinet_enabled" {
  description = "Create FortiGate AP ELB/ILB and FortiADC HA deployments"
  type        = bool
  default     = false
}

variable "snet_ids" {
  description = "FortiGate AP ELB/ILB and FortiADC HA deployment subnet ids"
  type        = map(any)
  default     = {}
}

variable "snet_address_ranges" {
  description = "FortiGate AP ELB/ILB and FortiADC HA deployment subnet address ranges"
  type        = map(any)
  default     = {}
}

variable "fortinet_licenses" {
  description = "FortiGate AP ELB/ILB and FortiADC HA deployment license files"
  type        = map(any)
  default     = {}
}

variable "fortinet_vm_publisher" {
  type    = string
  default = ""
}

variable "fortinet_vm_license_type" {
  type    = string
  default = ""
}

variable "fortigate_a_license_file" {
  type    = string
  default = ""
}

variable "fortigate_b_license_file" {
  type    = string
  default = ""
}

variable "fortigate_vm_offer" {
  type    = string
  default = ""
}

variable "fortigate_vm_sku" {
  type    = string
  default = ""
}

variable "fortigate_vm_size" {
  type    = string
  default = ""
}

variable "fortigate_vm_version" {
  type    = string
  default = ""
}

variable "fortigate_vm_username" {
  type    = string
  default = ""
}

variable "fortigate_vm_password" {
  type = string
  default = ""
}

variable "fortiadc_a_license_file" {
  type    = string
  default = ""
}

variable "fortiadc_b_license_file" {
  type    = string
  default = ""
}

variable "fortiadc_vm_offer" {
  type    = string
  default = ""
}

variable "fortiadc_vm_sku" {
  type    = string
  default = ""
}

variable "fortiadc_vm_size" {
  type    = string
  default = ""
}

variable "fortiadc_vm_version" {
  type    = string
  default = ""
}

variable "fortiadc_vm_username" {
  type    = string
  default = ""
}

variable "fortiadc_vm_password" {
  type = string
  default = ""
}

variable "fortinet_bastion_private_ip" {
  type    = string
  default = ""
}
