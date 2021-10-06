variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

variable "network_domain" {
  description = "hostname's network domain"
  type        = string
}

variable "drbd_count" {
  description = "number of hosts like this one"
  default     = 2
}

variable "drbd_disk_size" {
  description = "drbd partition disk size"
  default     = "1024000000" # 1GB
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP. It must be in other subnet than the machines!"
  type        = string
}

variable "nfs_mounting_point" {
  description = "Mounting point of the NFS share created in to of DRBD (`/mnt` must not be used in Azure)"
  type        = string
}

variable "nfs_export_name" {
  description = "Name of the created export in the NFS service. Usually, the `sid` of the SAP instances is used"
  type        = string
}

variable "fencing_mechanism" {
  description = "Choose the fencing mechanism for the cluster. Options: sbd"
  type        = string
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
  description = "iscsi server address"
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
  default     = 512
}

variable "vcpu" {
  description = "Number of virtual CPUs"
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

variable "network_name" {
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
