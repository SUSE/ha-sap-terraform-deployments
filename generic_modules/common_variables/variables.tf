variable "provider_type" {
  description = "Used provider for the deployment"
  type        = string
  validation {
    condition = (
      can(regex("^(aws|azure|gcp|libvirt|openstack)$", var.provider_type))
    )
    error_message = "Invalid provider type. Options: aws|azure|gcp|libvirt|openstack ."
  }
}

variable "region" {
  description = "Region where the machines are created"
  type        = string
  default     = ""
}

variable "deployment_name" {
  description = "Suffix string added to some of the infrastructure resources names. If it is not provided, the terraform workspace string is used as suffix"
  type        = string
  default     = ""
}

variable "deployment_name_in_hostname" {
  description = "Add deployment_name as a prefix to all hostnames."
  type        = bool
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
  description = "Repository url used to install development versions of HA/SAP deployment packages. If the SLE version is not present in the URL, it will be automatically detected"
  type        = string
  default     = ""
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  type        = list
  default     = []
}

variable "public_key" {
  description = "Content of a SSH public key or path to an already existing SSH public key. The key is only used to provision the machines and it is authorized for future accesses"
  type        = string
  default     = ""
}

variable "private_key" {
  description = "Content of a SSH private key or path to an already existing SSH private key. The key is only used to provision the machines. It is not uploaded to the machines in any case"
  type        = string
  default     = ""
}

variable "authorized_keys" {
  description = "List of additional authorized SSH public keys content or path to already existing SSH public keys to access the created machines with the used admin user (admin_user variable in this case)"
  type        = list(string)
  default     = []
}

variable "authorized_user" {
  description = "Authorized user for the given authorized_keys"
  type        = string
}

variable "bastion_enabled" {
  description = "Create a VM to work as a bastion to avoid the usage of public ip addresses and manage the ssh connection to the other machines"
  type        = bool
  default     = true
}

variable "bastion_public_key" {
  description = "Path to a SSH public key used to connect to the bastion. If it's not set the key provided in public_key_location will be used"
  type        = string
  default     = ""
}

variable "bastion_private_key" {
  description = "Path to a SSH private key used to connect to the bastion. If it's not set the key provided in private_key_location will be used"
  type        = string
  default     = ""
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "provisioning_log_level" {
  description = "Provisioning process log level. For salt: https://docs.saltstack.com/en/latest/ref/configuration/logging/index.html"
  type        = string
  default     = "error"
  validation {
    condition = (
      can(regex("^(quiet|critical|error|warning|info|profile|debug|trace|garbage|all)$", var.provisioning_log_level))
    )
    error_message = "Invalid salt log level. Options: quiet|critical|error|warning|info|profile|debug|trace|garbage|all ."
  }
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  type        = bool
  default     = false
}

variable "monitoring_enabled" {
  description = "Enable centralized monitoring via Prometheus/Grafana/Loki"
  type        = bool
  default     = false
}

variable "monitoring_srv_ip" {
  description = "Monitoring server address"
  type        = string
  default     = ""
}

variable "qa_mode" {
  description = "Enable test/qa mode (disable extra packages usage not coming in the image)"
  type        = bool
  default     = false
}

variable "provisioning_output_colored" {
  description = "Print colored output of the provisioning execution"
  type        = bool
  default     = true
}
