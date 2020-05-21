variable "machine_type_iscsi_server" {
  type    = string
  default = "custom-1-2048"
}

variable "compute_zones" {
  description = "gcp compute zones data"
  type        = list(string)
}

variable "network_subnet_name" {
  description = "Subnet name to attach the network interface of the nodes"
  type        = string
}

variable "iscsi_server_boot_image" {
  type    = string
  default = "suse-byos-cloud/sles-15-sap-byos"
}

variable "iscsi_srv_ip" {
  description = "IP for iSCSI server"
}

variable "iscsidev" {
  description = "Disk device where iscsi partitions are created"
  type        = string
  default     = "/dev/sdb"
}

variable "iscsi_disks" {
  description = "Number of partitions attach to iscsi server. 0 means `all`."
  default     = 0
}

variable "public_key_location" {
  description = "Path to a SSH public key used to connect to the created machines"
  type        = string
}

variable "private_key_location" {
  description = "Path to a SSH private key used to connect to the created machines"
  type        = string
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
  description = "Extra packages which should be installed"
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

variable "on_destroy_dependencies" {
  description = "Resources objects need in the on_destroy script (everything that allows ssh connection)"
  type        = any
  default     = []
}
