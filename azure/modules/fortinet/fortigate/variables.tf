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
  type        = map(any)
}

variable "snet_address_ranges" {
  description = "Subnet address range list of the FortiGate subnets"
  type        = map(any)
}

variable "storage_account" {
  description = "Storage account where the boot diagnostics will be stored"
  type        = string
}

variable "vnet_address_range" {
  type = string
}

variable "os_image" {
  description = "OS image used to create this module machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: fortinet:fortinet_fortigate-vm_v5:fortinet_fg-vm:7.0.2"
  type        = string
}

variable "vm_size" {
  type = string
}

variable "vm_license" {
  type = string
}

variable "vm_username" {
  type = string
}

variable "vm_password" {
  type = string
}

variable "bastion_private_ip" {
  type = string
}

variable "netweaver_private_ips" {
  type = list(any)
}

variable "fortinet_licenses" {
  type = map(any)
}

variable "resource_group_id" {
  type = string
}

variable "vnet_spoke_address_range" {
  type = string
}
