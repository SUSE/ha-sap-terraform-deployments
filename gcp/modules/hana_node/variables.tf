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

variable "machine_type_majority_maker" {
  description = "The instance type of the hana majority_maker"
  type        = string
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

variable "majority_maker_ip" {
  description = "ip address to set to the HANA Majority Maker node. If it's not set the addresses will be auto generated from the provided vnet address range"
  type        = string
  validation {
    condition = (
      var.majority_maker_ip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.majority_maker_ip))
    )
    error_message = "Invalid IP address format."
  }
}

variable "iscsi_srv_ip" {
  description = "iscsi server address"
  type        = string
}


variable "hana_data_disks_configuration" {
  type        = map(any)
  default     = {}
  description = <<EOF
    This map describes how the disks will be formatted to create the definitive configuration during the provisioning.

    disks_type and disks_size are used during the disks creation. The number of elements must match in all of them
    "," is used to separate each disk.

    disk_type = The disk type used to create disks. See https://cloud.google.com/compute/docs/disks and https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk for reference.
    disk_size = The disk size in GB.

    luns, names, lv_sizes and paths are used during the provisioning to create/format/mount logical volumes and filesystems.
    "#" character is used to split the volume groups, while "," is used to define the logical volumes for each group
    The number of groups split by "#" must match in all of the entries.

    luns  -> The luns or disks used for each volume group. The number of luns must match with the configured in the previous disks variables (example 0,1#2,3#4#5#6)
    names -> The names of the volume groups and logical volumes (example data#log#shared#usrsap#backup)
    lv_sizes -> The size in % (from available space) dedicated for each logical volume and folder (example 50#50#100#100#100)
    paths -> Folder where each volume group will be mounted (example /hana/data,/hana/log#/hana/shared#/usr/sap#/hana/backup#/sapmnt/)
  EOF
}

variable "filestore_tier" {
  description = "service level / tier for filestore shared Storage"
  type        = string
  validation {
    condition = (
      can(regex("^(BASIC_SSD|ENTERPRISE)$", var.filestore_tier))
    )
    error_message = "Invalid filestore Pool service level. Options: BASIC_SSD|ENTERPRISE."
  }
}

variable "hana_scale_out_filestore_quota_data" {
  description = "Quota for filestore shared storage volume HANA scale-out data"
  type        = number
}

variable "hana_scale_out_filestore_quota_log" {
  description = "Quota for filestore shared storage volume HANA scale-out log"
  type        = number
}

variable "hana_scale_out_filestore_quota_backup" {
  description = "Quota for filestore shared storage volume HANA scale-out backup"
  type        = number
}

variable "hana_scale_out_filestore_quota_shared" {
  description = "Quota for filestore shared storage volume HANA scale-out shared"
  type        = number
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
