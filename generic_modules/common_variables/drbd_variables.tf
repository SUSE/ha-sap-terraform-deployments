variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP."
  type        = string
}

variable "drbd_cluster_vip_mechanism" {
  description = "Mechanism used to manage the virtual IP address in the drbd cluster."
  type        = string
}

variable "drbd_cluster_fencing_mechanism" {
  description = "Select the DRBD cluster fencing mechanism. Options: sbd"
  type        = string
}

variable "drbd_sbd_storage_type" {
  description = "Choose the SBD storage type. Options: iscsi, shared-disk(this option available in Libvirt only)"
  type        = string
}
