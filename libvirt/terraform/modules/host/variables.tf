variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type        = "map"
}

variable "name" {
  description = "hostname, without the domain part"
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

variable "count" {
  description = "number of hosts like this one"
  default     = 1
}

variable "grains" {
  description = "custom grain string to be added to this host's configuration"
  default     = ""
}

variable "public_key_location" {
  description = "path of additional pub ssh key you want to use to access VMs"
  default     = "/dev/null"

  # HACK: "" cannot be used as a default because of https://github.com/hashicorp/hil/issues/50
}

variable "hana_disk_size" {
  description = "hana partition disk size"
  default     = "68719476736"              # 64GB
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = "list"
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

variable "running" {
  description = "whether this host should be turned on or off"
  default     = true
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default     = ""
}

variable "additional_disk" {
  description = "disk block definition(s) to be added to this host"
  default     = []
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  default     = true
}
