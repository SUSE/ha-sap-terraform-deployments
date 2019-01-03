variable "timezone" {
  description = "Timezone setting for all VMs"
  default = "Europe/Berlin"
}

variable "ssh_key_path" {
  description = "path of pub ssh key you want to use to access VMs, see libvirt/README.md"
  default = "~/.ssh/id_rsa.pub"
}

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}

variable "name_prefix" {
  description = "a prefix for all names of objects to avoid collisions. Eg. moio-"
  default = ""
}

variable "use_shared_resources" {
  description = "use true to avoid deploying images, mirrors and other shared infrastructure resources"
  default = false
}

variable "additional_network" {
  description = "whether to use an additional network or not"
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

variable "images" {
  description = "list of images to be uploaded to the libvirt host, leave default for all"
  default = ["sles15", "sles11sp4", "sles12", "sles12sp1", "sles12sp2", "sles12sp3", "sles12sp4"]
  type = "list"
}
