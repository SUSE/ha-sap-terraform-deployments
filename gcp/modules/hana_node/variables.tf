variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "bastion_host" {
  description = "Bastion host address"
  type        = string
  default     = ""
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "hana_count" {
  type    = string
  default = "2"
}

variable "machine_type" {
  type    = string
  default = "n1-highmem-32"
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

variable "os_image" {
  description = "Image used to create the machine"
  type        = string
}

variable "network_domain" {
  description = "hostname's network domain"
  type        = string
}

variable "gcp_credentials_file" {
  description = "Path to your local gcp credentials file"
  type        = string
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "iscsi_srv_ip" {
  description = "iscsi server address"
  type        = string
}

variable "hana_data_disk_type" {
  description = "Disk type of the disks used to store hana database content"
  type        = string
  default     = "pd-ssd"
}

variable "hana_data_disk_size" {
  description = "Disk size of the disks used to store hana database content"
  type        = string
  default     = "834"
}

variable "hana_backup_disk_type" {
  description = "Disk type of the disks used to store hana database backup content"
  type        = string
  default     = "pd-standard"
}

variable "hana_backup_disk_size" {
  description = "Disk size of the disks used to store hana database backup content"
  type        = string
  default     = "416"
}

variable "hana_disk_device" {
  description = "Device where hana is installed"
  type        = string
  default     = "/dev/sdb"
}

variable "hana_backup_device" {
  description = "Device where hana backup is stored"
  type        = string
  default     = "/dev/sdc"
}

variable "hana_inst_disk_device" {
  description = "Device where hana installation software CIFS share is mounted"
  type        = string
  default     = "/dev/sdd"
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
