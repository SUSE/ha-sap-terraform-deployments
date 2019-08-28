variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

variable "public_key_location" {
  description = "path of pub ssh key you want to use to access VMs"
  default     = "~/.ssh/id_rsa.pub"
}

variable "domain" {
  description = "hostname's domain"
  default     = "tf.local"
}


// Provider-specific variables

variable "pool" {
  description = "libvirt storage pool name for VM disks"
  default     = "default"
}

variable "network_name" {
  description = "libvirt NAT network name for VMs, use empty string for bridged networking"
  default     = "default"
}

variable "bridge" {
  description = "a bridge device name available on the libvirt host, leave default for NAT"
  default     = ""
}

