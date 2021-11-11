variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "bastion_host" {
  description = "Bastion host address"
  type        = string
  default     = ""
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

variable "az_region" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type = string
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "network_domain" {
  description = "hostname's network domain"
  type        = string
}

variable "network_subnet_id" {
  type = string
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

variable "storage_account" {
  type = string
}

variable "os_image" {
  description = "sles4sap image used to create this module machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
}

variable "monitoring_uri" {
  type    = string
  default = ""
}

variable "monitoring_srv_ip" {
  description = "monitoring server address"
  type        = string
  default     = ""
}

variable "vnet_name" {
  description = "Virtual network where the monitoring subnet will be created"
  type        = string
}

variable "snet_id" {
  description = "Existing Virtual subnet ID where the monitoring subnet will be created"
  type        = string
  default     = ""
}

variable "snet_address_range" {
  description = "Subnet address range of the monitoring subnet"
}
