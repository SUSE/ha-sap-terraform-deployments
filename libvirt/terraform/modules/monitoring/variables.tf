variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type        = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  default     = "grafana"
}

variable "count" {
  description = "number of hosts like this one"
  default     = 1
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default     = 1
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

variable "additional_packages" {
  description = "extra packages which should be installed"
  default     = []
}

variable "additional_repos" {
  description = "extra repositories used for installation {label = url}"
  default     = {}
}

variable "ha_sap_deployment_repo" {
  description = "Repository url used to install install HA/SAP deployment packages"
  type        = "string"
}

// TODO: verify if it is needed
// variable "server_configuration" {
//   description = "use ${module.<SERVER_NAME>.configuration}, see the main.tf example file"
//  type = "map"
//}

variable "public_key_location" {
  description = "path of additional pub ssh key you want to use to access VMs"
  default     = "/dev/null"

  # HACK: "" cannot be used as a default because of https://github.com/hashicorp/hil/issues/50
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  default     = false
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = "list"
}

// Provider-specific variables

variable "memory" {
  description = "RAM memory in MiB"
  default     = 512
}

variable "running" {
  description = "Whether this host should be turned on or off"
  default     = true
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default     = ""
}

variable "cpu_model" {
  description = "Define what CPU model the guest is getting (host-model, host-passthrough or the default)."
  default     = ""
}
