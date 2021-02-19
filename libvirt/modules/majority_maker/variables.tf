variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "majority_maker_image" {
  description = "Majority maker machine base image"
  type        = string
  default     = ""
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

variable "name" {
  description = "hostname, without the domain part"
  default     = "majoritymaker"
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

variable "majority_maker_enabled" {
  description = "whether or not to enable this module"
  type        = bool
  default     = false
}

variable "cluster_ips" {
  description = "ip addresses of the rest of the cluster nodes"
  type        = list(string)
}

variable "majority_maker_ip" {
  description = "Majority maker machine address"
  type        = string
}

variable "sbd_enabled" {
  description = "Enable sbd usage in the HA cluster"
  type        = bool
  default     = true
}

variable "sbd_storage_type" {
  description = "Choose the SBD storage type. Options: iscsi, shared-disk"
  type        = string
  default     = "shared-disk"
}

variable "sbd_disk_id" {
  description = "SBD disk volume id. Only used if sbd_storage_type is shared-disk"
  type        = string
}

variable "iscsi_srv_ip" {
  description = "iscsi server address. Only used if sbd_storage_type is iscsi"
  type        = string
  default     = ""
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
  default     = 4096
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default     = 1
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default     = ""
}

variable "cpu_model" {
  description = "Define what CPU model the guest is getting (host-model, host-passthrough or the default)."
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

variable "storage_pool" {
  description = "libvirt storage pool name for VM disks"
  default     = "default"
}