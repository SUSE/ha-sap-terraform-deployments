variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "az_region" {
  description = "Azure region where the deployment machines will be created"
  type        = string
  default     = "westeurope"
}

variable "os_image" {
  description = "sles4sap image used to create this module machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
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

variable "network_topology" {
  description = "Network topolgy to use."
  type        = string
}

variable "vnet_name" {
  description = "Virtual network where the bastion subnet will be created"
  type        = string
}

variable "snet_ids" {
  description = "Existing Virtual subnet ID where the bastion subnet will be created"
  type        = list(string)
  default     = []
}

variable "snet_address_range" {
  description = "Subnet address range of the fortigate subnets"
  type        = list(string)
  default     = []
}

variable "snet_address_ranges" {
  description = "Subnet address range list of the fortigate subnets"
  type        = list(string)
  default     = []
}

variable "storage_account" {
  description = "Storage account where the boot diagnostics will be stored"
  type        = string
}
