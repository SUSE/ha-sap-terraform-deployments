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

variable "subnet_mgmt_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created named snet-{{var.deployment_name/terraform.workspace}}"
  type        = string
  default = ""
}

variable "subnet_mgmt_address_range" {
  description = "subnet address range in CIDR notation (only used if the subnet is created by terraform or the user doesn't have read permissions in this resource. To use the current vnet address range set the value to an empty string)"
  type        = string
  default = ""
  validation {
    condition = (
      var.subnet_mgmt_address_range == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_mgmt_address_range))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
}

variable "subnet_gateway_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created named snet-{{var.deployment_name/terraform.workspace}}"
  type        = string
  default = ""
}

variable "subnet_gateway_address_range" {
  description = "subnet address range in CIDR notation (only used if the subnet is created by terraform or the user doesn't have read permissions in this resource. To use the current vnet address range set the value to an empty string)"
  type        = string
  default = ""
  validation {
    condition = (
      var.subnet_gateway_address_range == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_gateway_address_range))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
}

variable "bastion_os_image" {
  description = "sles4sap image used to create the bastion machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
  default     = "SUSE:sles-sap-15-sp2:gen2:latest"
}

variable "bastion_user" {
  type = string
  default = "sles"
}

variable "bastion_public_key" {
  description = "Content of a SSH public key or path to an already existing SSH public key to the bastion. If it's not set the key provided in public_key will be used"
  type        = string
  default     = ""
}

variable "bastion_private_key" {
  description = "Content of a SSH private key or path to an already existing SSH private key to the bastion. If it's not set the key provided in private_key will be used"
  type        = string
  default     = ""
}

# Deployment variables

# variable "deployment_name" {
#   description = "Suffix string added to some of the infrastructure resources names. If it is not provided, the terraform workspace string is used as suffix"
#   type        = string
# }

variable "network_topology" {
  description = "Network topolgy to use."
  type        = string
}
