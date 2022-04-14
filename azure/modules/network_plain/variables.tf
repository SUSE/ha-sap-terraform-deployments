variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "deployment_name" {
  description = "Suffix string added to some of the infrastructure resources names. If it is not provided, the terraform workspace string is used as suffix"
  type        = string
}

# Azure related variables

variable "az_region" {
  description = "Azure region where the deployment machines will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Already existing resource group where the infrastructure is created. If it's not set a new one will be created named rg-ha-sap-{{var.deployment_name/terraform.workspace}}"
  type        = string
}

variable "vnet_name" {
  description = "Already existing virtual network name used by the created infrastructure. If it's not set a new one will be created named vnet-{{var.deployment_name/terraform.workspace}}"
  type        = string
}

variable "vnet_address_range" {
  description = "vnet address range in CIDR notation (only used if the vnet is created by terraform or the user doesn't have read permissions in this resource. To use the current vnet address range set the value to an empty string)"
  type        = string
  validation {
    condition = (
      can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vnet_address_range))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
}

variable "subnet_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created named snet-{{var.deployment_name/terraform.workspace}}"
  type        = string
}

variable "subnet_address_range" {
  description = "subnet address range in CIDR notation (only used if the subnet is created by terraform or the user doesn't have read permissions in this resource. To use the current vnet address range set the value to an empty string)"
  type        = string
  validation {
    condition = (
      var.subnet_address_range == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_address_range))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
}

variable "subnet_netapp_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created named snet-{{var.deployment_name/terraform.workspace}}"
  type        = string
  default     = ""
}

variable "subnet_netapp_address_range" {
  description = "subnet address range in CIDR notation (only used if the subnet is created by terraform or the user doesn't have read permissions in this resource. To use the current vnet address range set the value to an empty string)"
  type        = string
  validation {
    condition = (
      var.subnet_netapp_address_range == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_netapp_address_range))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
}

variable "anf_account_name" {
  description = "Name of ANF Accounts"
  type        = string
  default     = ""
}

variable "anf_pool_name" {
  description = "Name if ANF Pool"
  type        = string
  default     = ""
}

