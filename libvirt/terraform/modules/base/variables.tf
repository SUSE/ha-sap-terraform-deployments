variable "timezone" {
  description = "Timezone setting for all VMs"
  default = "Europe/Berlin"
}

variable "ssh_key_path" {
  description = "path of pub ssh key you want to use to access VMs"
  default = "~/.ssh/id_rsa.pub"
}

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}

variable "name_prefix" {
  description = "a prefix for all names of objects to avoid collisions."
  default = ""
}

variable "use_shared_resources" {
  description = "use true to avoid deploying images, mirrors and other shared infrastructure resources"
  default = false
}

variable "iprange" {
  description = "Used host ip addresses range"
  type = "string"
}

// Provider-specific variables

variable "pool" {
  description = "libvirt storage pool name for VM disks"
  default = "default"
}

variable "network_name" {
  description = "libvirt NAT network name for VMs, use empty string for bridged networking"
  default = "default"
}

variable "bridge" {
  description = "a bridge device name available on the libvirt host, leave default for NAT"
  default = ""
}

variable "image" {
  description = "path or url of the base image"
}
