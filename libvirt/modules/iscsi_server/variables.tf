variable "iscsi_srv_ip" {
  description = "iscsi server address"
  type        = string
}

variable "iscsidev" {
  description = "device iscsi for iscsi server"
  type        = string
}

variable "iscsi_disks" {
  description = "number of partitions attach to iscsi server. 0 means `all`."
  default     = 0
}

variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages"
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
  type        = map
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
  type        = bool
  default     = false
}

// Provider-specific variables

variable "source_image" {
  description = "Source image used to boot the machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "volume_name" {
  description = "Already existing volume name used to boot the machines. It must be in the same storage pool. It's only used if source_image is not provided"
  type        = string
  default     = ""
}

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

variable "isolated_network_id" {
  description = "Network id, internally created by terraform"
  type        = string
}

variable "isolated_network_name" {
  description = "Network name to attach the isolated network interface"
  type        = string
}

variable "nat_network_name" {
  description = "libvirt NAT network name for VMs, use empty string for bridged networking"
  default     = ""
}

variable "bridge" {
  description = "a bridge device name available on the libvirt host, leave default for NAT"
  default     = ""
}

variable "storage_pool" {
  description = "libvirt storage pool name for VM disks"
  default     = "default"
}

# Specific QA variables
variable "qa_mode" {
  description = "define qa mode (Disable extra packages outside images)"
  type        = bool
  default     = false
}
