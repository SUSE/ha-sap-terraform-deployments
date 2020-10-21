variable "bastion_enabled" {
  description = "Enable bastion machine creation"
  type        = bool
  default     = true
}

variable "az_region" {
  description = "Azure region where the deployment machines will be created"
  type    = string
  default = "westeurope"
}

variable "vm_size" {
  description = "Bastion machine vm size"
  type        = string
  default     = "Standard_B1s"
}

variable "resource_group_name" {
  description = "Resource group name where the bastion will be created"
  type        = string
}

variable "vnet_name" {
  description = "Virtual network where the bastion subnet will be created"
  type        = string
}

variable "snet_address_range" {
  description = "Subnet address range of the bastion subnet"
}

variable "deployment_name" {
  description = "Name used to complement some of the infrastructure resources name as sufix. If it is not provided, the terraform workspace string is used"
  type        = string
}

variable "admin_user" {
  description = "Administration user used to create the machines"
  type        = string
  default     = "azadmin"
}

variable "public_key" {
  description = "Content of a SSH private key or path to an already existing SSH private key to the bastion"
  type        = string
}

variable "storage_account" {
  description = "Storage account where the boot diagnostics will be stored"
  type = string
}
