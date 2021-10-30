variable "fortinet_enabled" {
  type = bool
}

variable "subnet_dmz_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created named snet-{{var.deployment_name/terraform.workspace}}"
  type        = string
  default     = ""
}

variable "subnet_dmz_address_range" {
  description = "subnet address range in CIDR notation (only used if the subnet is created by terraform or the user doesn't have read permissions in this resource. To use the current vnet address range set the value to an empty string)"
  type        = string
  default     = ""
  validation {
    condition = (
      var.subnet_dmz_address_range == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_dmz_address_range))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
}

variable "subnet_trusted_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created named snet-{{var.deployment_name/terraform.workspace}}"
  type        = string
  default     = ""
}

variable "subnet_trusted_address_range" {
  description = "subnet address range in CIDR notation (only used if the subnet is created by terraform or the user doesn't have read permissions in this resource. To use the current vnet address range set the value to an empty string)"
  type        = string
  default     = ""
  validation {
    condition = (
      var.subnet_trusted_address_range == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_trusted_address_range))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
}

variable "subnet_hasync_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created named snet-{{var.deployment_name/terraform.workspace}}"
  type        = string
  default     = ""
}

variable "subnet_hasync_address_range" {
  description = "subnet address range in CIDR notation (only used if the subnet is created by terraform or the user doesn't have read permissions in this resource. To use the current vnet address range set the value to an empty string)"
  type        = string
  default     = ""
  validation {
    condition = (
      var.subnet_hasync_address_range == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_hasync_address_range))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
}

variable "subnet_fortinet_mgmt_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created named snet-{{var.deployment_name/terraform.workspace}}"
  type        = string
  default     = ""
}

variable "subnet_fortinet_mgmt_address_range" {
  description = "subnet address range in CIDR notation (only used if the subnet is created by terraform or the user doesn't have read permissions in this resource. To use the current vnet address range set the value to an empty string)"
  type        = string
  default     = ""
  validation {
    condition = (
      var.subnet_fortinet_mgmt_address_range == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_fortinet_mgmt_address_range))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
}

variable "subnet_shared_services_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created named snet-{{var.deployment_name/terraform.workspace}}"
  type        = string
  default     = ""
}

variable "subnet_shared_services_address_range" {
  description = "subnet address range in CIDR notation (only used if the subnet is created by terraform or the user doesn't have read permissions in this resource. To use the current vnet address range set the value to an empty string)"
  type        = string
  default     = ""
  validation {
    condition = (
      var.subnet_shared_services_address_range == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_shared_services_address_range))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
}