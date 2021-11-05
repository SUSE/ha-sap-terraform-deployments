variable "fortinet_enabled" {
  description = "Create FortiGate AP ELB/ILB and FortiADC HA deployments"
  type        = bool
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
  default = {}
}

variable "fortinet_vm_publisher" {
  type    = string
}

variable "fortinet_vm_license_type" {
  type    = string
}

variable "fortigate_a_license_file" {
  type    = string
}

variable "fortigate_b_license_file" {
  type    = string
}

variable "fortigate_vm_offer" {
  type    = string
}

variable "fortigate_vm_sku" {
  type    = string
}

variable "fortigate_vm_size" {
  type    = string
}

variable "fortigate_vm_version" {
  type    = string
}

variable "fortigate_vm_username" {
  type    = string
}

variable "fortigate_vm_password" {
  type    = string
}

variable "fortiadc_a_license_file" {
  type    = string
}

variable "fortiadc_b_license_file" {
  type    = string
}
variable "fortiadc_vm_offer" {
  type    = string
}

variable "fortiadc_vm_sku" {
  type    = string
}

variable "fortiadc_vm_size" {
  type    = string
}

variable "fortiadc_vm_version" {
  type    = string
}

variable "fortiadc_vm_username" {
  type    = string
}

variable "fortiadc_vm_password" {
  type    = string
}

variable "bastion_private_ip" {
  type = string
}