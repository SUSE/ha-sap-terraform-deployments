variable "az_region" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type = string
}

variable "network_subnet_id" {
  type = string
}

variable "sec_group_id" {
  type = string
}

variable "storage_account" {
  type = string
}

variable "iscsi_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "iscsi_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "iscsi_public_sku" {
  type    = string
  default = "15"
}

variable "iscsi_public_version" {
  type    = string
  default = "latest"
}

variable "iscsi_srv_uri" {
  type    = string
  default = ""
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "admin_user" {
  type    = string
  default = "azadmin"
}

variable "public_key_location" {
  type = string
}

variable "private_key_location" {
  type = string
}

variable "bastion_enabled" {
  description = "Use a bastion machine to create the ssh connections"
  type        = bool
  default     = true
}

variable "bastion_host" {
  description = "Bastion host address. "
  type        = string
  default     = ""
}

variable "iscsi_count" {
  description = "Number of iscsi machines to deploy"
  type        = number
}

variable "host_ips" {
  description = "List of ip addresses to set to the machines"
  type        = list(string)
}

variable "iscsi_disk_size" {
  description = "Disk size in GB used to create the LUNs and partitions to be served by the ISCSI service"
  type        = number
  default     = 10
}

variable "lun_count" {
  description = "Number of LUN (logical units) to serve with the iscsi server. Each LUN can be used as a unique sbd disk"
  type        = number
  default     = 3
}

variable "reg_code" {
  description = "If informed, register the product using SUSEConnect"
  default     = ""
}

variable "reg_email" {
  description = "Email used for the registration"
  default     = ""
}

variable "reg_additional_modules" {
  description = "Map of the modules to be registered. Module name = Regcode, when needed."
  type        = map(string)
  default     = {}
}

variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages"
  type        = string
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  default     = []
}

variable "qa_mode" {
  description = "Whether or not to install the HA/SAP packages from the `ha_sap_deployment_repo`"
  type        = bool
  default     = false
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  type        = bool
  default     = false
}
