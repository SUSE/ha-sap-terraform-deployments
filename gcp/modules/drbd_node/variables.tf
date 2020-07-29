variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-4"
}

variable "compute_zones" {
  description = "gcp compute zones data"
  type        = list(string)
}

variable "network_name" {
  description = "Network to attach the static route (temporary solution)"
  type        = string
}

variable "network_subnet_name" {
  description = "Subnet name to attach the network interface of the nodes"
  type        = string
}

variable "drbd_count" {
  description = "Cound of drbd cluster nodes"
  type        = string
  default     = "2"
}

variable "drbd_image" {
  description = "image of the drbd nodes"
  type        = string
  default     = "suse-byos-cloud/sles-15-sap-byos"
}

variable "drbd_data_disk_size" {
  description = "drbd data disk size"
  type        = string
  default     = "10"
}

variable "drbd_data_disk_type" {
  description = "drbd data disk type"
  type        = string
  default     = "pd-standard"
}

variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP. It must be in other subnet than the machines!"
  type        = string
}

variable "gcp_credentials_file" {
  description = "Path to your local gcp credentials file"
  type        = string
}

variable "network_domain" {
  description = "hostname's network domain"
  default     = "tf.local"
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "sbd_enabled" {
  description = "Enable sbd usage in the HA cluster"
  type        = bool
  default     = false
}

variable "sbd_storage_type" {
  description = "Choose the SBD storage type. Options: iscsi"
  type        = string
  default     = "iscsi"
}

variable "iscsi_srv_ip" {
  description = "IP for iSCSI server"
  type        = string
}

variable "cluster_ssh_pub" {
  description = "path for the public key needed by the cluster"
  type        = string
}

variable "cluster_ssh_key" {
  description = "path for the private key needed by the cluster"
  type        = string
}

variable "on_destroy_dependencies" {
  description = "Resources objects need in the on_destroy script (everything that allows ssh connection)"
  type        = any
  default     = []
}
