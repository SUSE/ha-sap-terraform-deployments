variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "region" {
  description = "GCP region where the bastion subnet is deployed"
  type        = string
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "os_image" {
  description = "Image used to create the machine"
  type        = string
}

variable "network_domain" {
  description = "hostname's network domain"
  type        = string
}

variable "vm_size" {
  description = "Bastion machine vm size"
  type        = string
  default     = "custom-1-2048"
}

variable "compute_zones" {
  description = "gcp compute zones data"
  type        = list(string)
}

variable "network_link" {
  description = "Network link"
  type        = string
}

variable "snet_address_range" {
  description = "Subnet address range of the bastion subnet"
  type        = string
}

variable "on_destroy_dependencies" {
  description = "Resources objects need in the on_destroy script (everything that allows ssh connection)"
  type        = any
  default     = []
}
