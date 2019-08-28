variable "base_configuration" {
  description = "use module.base.configuration see the main.tf example file"
  type        = "map"
}

variable "iscsi_image" {
  description = "iscsi server base image"
  type        = "string"
}

variable "iscsi_srv_ip" {
  description = "iscsi server address"
  type        = "string"
}

variable "iscsidev" {
  description = "device iscsi for iscsi server"
  type        = "string"
}

variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages"
  type        = "string"
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
  type        = "map"
  default     = {}
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}"
  default     = {}
}

variable "additional_packages" {
  description = "extra packages to install"
  default     = []
}

variable "iscsi_count" {
  description = "number of hosts like this one"
  default     = 1
}

variable "grains" {
  description = "custom grain string to be added to this host's configuration"
  default     = ""
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  default     = false
}

// Provider-specific variables

variable "memory" {
  description = "RAM memory in MiB"
  default     = 512
}

variable "vcpu" {
  description = "number of virtual CPUs"
  default     = 1
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default     = ""
}

# Specific QA variables
variable "qa_mode" {
  description = "define qa mode (Disable extra packages outside images)"
  default     = false
}
