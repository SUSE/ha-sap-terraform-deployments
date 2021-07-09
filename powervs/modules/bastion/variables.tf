variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "ibmcloud_api_key" {
  type    = string
}

variable "region" {
  type    = string
  default = "eu-de"
}

variable "zone" {
  type    = string
  default = "eu-de-1"
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

variable "vcpu" {
  description = "Number of CPUs for the bastion machine"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory (in GBs) for the bastion machine"
  type        = number
  default     = 8
}

#variable "resource_group_name" {
#  description = "Resource group name where the bastion will be created"
#  type        = string
#}

#variable "vnet_name" {
#  description = "Virtual network where the bastion subnet will be created"
#  type        = string
#}

#variable "snet_address_range" {
#  description = "Subnet address range of the bastion subnet"
#}

#variable "storage_account" {
#  description = "Storage account where the boot diagnostics will be stored"
#  type = string
#}

variable "pi_cloud_instance_id" {
  description = "The GUID of the service instance associated with an account."
  default     = ""
}

variable "pi_key_pair_name" {
  description = "The name of the SSH key that you want to use to access your Power Systems Virtual Server instance. The SSH key must be uploaded to IBM Cloud."
  default     = ""
}

variable "pi_sys_type" {
  description = "The type of system on which to create the VM."
  default     = ""
}

variable "pi_network_ids" {
  description = "The list of network IDs that you want to assign to the instance."
  type        = list(string)
  default     = []
}

variable "public_pi_network_names" {
  description = "The list of public network names that you want to assign to an instance."
  type        = list(string)
  default     = []
}

variable "private_pi_network_names" {
  description = "The list of private network names that you want to assign to an instance.  If bastion_enabled = true then private_pi_network_ids cannot be blank."
  type        = list(string)
  default     = []
}
