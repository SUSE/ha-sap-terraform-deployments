variable "monitoring_image" {
  description = "monitoring server base image"
  type        = "string"
  default     = ""
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

variable "name" {
  description = "hostname, without the domain part"
  default     = "grafana"
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

variable "network_domain" {
  description = "hostname's network domain"
  default     = "tf.local"
}

variable "network_name" {
  description = "libvirt NAT network name for VMs, use empty string for bridged networking"
  default     = ""
}

variable "bridge" {
  description = "a bridge device name available on the libvirt host, leave default for NAT"
  default     = ""
}

variable "monitoring_count" {
  description = "number of hosts like this one"
  default     = 1
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default     = 1
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  default     = []
}

variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages"
  type        = "string"
}

variable "public_key_location" {
  description = "path of pub ssh key you want to use to access VMs"
  default     = "~/.ssh/id_rsa.pub"
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  default     = false
}

variable "monitoring_srv_ip" {
  description = "monitoring server address"
  type        = string
}

// Provider-specific variables

variable "base_image_id" {
  description = "it is the centralized images used by the module. It is created in main.tf"
  type        = string
}

variable "memory" {
  description = "RAM memory in MiB"
  default     = 4096
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default     = ""
}

variable "cpu_model" {
  description = "Define what CPU model the guest is getting (host-model, host-passthrough or the default)."
  default     = ""
}


variable "network_id" {
  description = "network id to be injected into domain. normally the isolated network is created in main.tf"
  type        = string
}

variable "pool" {
  description = "libvirt storage pool name for VM disks"
  default     = "default"
}


variable "monitored_hosts" {
  description = "IPs of hosts you want to monitor"
  type        = list(string)
}
