variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "az_region" {
  description = "Azure region where the FortiGates will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where the FortiGates will be created"
  type        = string
}

variable "snet_ids" {
  description = "FortiGate Virtual subnet IDs"
  type        = list(string)
  default     = []
}

variable "snet_address_ranges" {
  description = "Subnet address range list of the FortiGate subnets"
  type        = list(string)
  default     = []
}

variable "storage_account" {
  description = "Storage account where the boot diagnostics will be stored"
  type        = string
}

variable "vnet_address_range" {
  type = string
}

variable "vm_offer"     {
  type = string
}
variable "vm_sku"       {
  type = string
}
variable "vm_publisher" {
  type = string
}
variable "vm_size"      {
  type = string
}

variable "vm_license"   {
  type = string
}

variable "vm_version"   {
  type = string
}

variable "vm_username"  {
  type = string
}

variable "vm_password" {
  type = string
}