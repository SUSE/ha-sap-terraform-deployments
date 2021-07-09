variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "ibmcloud_api_key" {
  type    = string
}

variable "region" {
  type    = string
  default = "eu-de"
}

variable "zone" {
  type    = string
  default = "eu-de-1"
}

variable "bastion_host" {
  description = "Bastion host address"
  type        = string
  default     = ""
}

variable "bastion_private" {
  description = "Bastion private host address"
  type        = string
  default     = ""
}

variable "bastion_enabled" {
  description = "Create a VM to work as a bastion to avoid the usage of public ip addresses and manage the ssh connection to the other machines"
  type        = bool
  default     = true
}

variable "hana_count" {
  type    = string
  default = "2"
}

variable "name" {
  type    = string
  default = "hana"
}

variable "vcpu" {
  description = "Number of CPUs for the HANA machines"
  type        = number
  default     = 4
}

variable "memory" {
  description = "Memory (in GBs) for the HANA machines"
  type        = number
  default     = 32
}

#variable "host_ips" {
#  description = "ip addresses to set to the nodes"
#  type        = list(string)
#}

variable "sbd_disk_id" {
  description = "SBD id. Only used if sbd_storage_type is shared-disk"
  type        = string
}

variable "sbd_disk_wwn" {
  description = "SBD wwn. Only used if sbd_storage_type is shared-disk"
  type        = string
}

variable "os_image" {
  description = "sles4sap image used to create a HANA node."
  type        = string
}

variable "hana_instance_number" {
  description = "Instance number of the HANA system. It must be a 2 digits string. Examples: 00, 01, 10"
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

variable "hana_data_disks_configuration" {
  type = map
  default = {
    disks_type       = "tier1,tier1,tier1,tier1,tier1,tier1,tier1"
    disks_size       = "128,128,128,128,128,128,128"
    # The next variables are used during the provisioning
    luns     = "0,1#2,3#4#5#6"
    names    = "data#log#shared#usrsap#backup"
    lv_sizes = "100#100#100#100#100"
    paths    = "/hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup"
  }
  description = <<EOF
    This map describes how the disks will be formatted to create the definitive configuration during the provisioning.
    disks_per_instance, disks_type, disks_size are used during the disks creation. The number of disks much match number of luns.
    "#" character is used to split the volume groups, while "," is used to define the logical volumes for each group
    The number of groups split by "#" must match the number of disks.
    names -> The names of the volume groups (example datalog#shared#usrsap#backup)
    luns  -> The luns or disks used for each volume group. The number of luns must match with the configured in the previous disks variables (example 0,1,2#3#4#5)
    sizes -> The size dedicated for each logical volume and folder (example 70,100#100#100#100)
    paths -> Folder where each volume group will be mounted (example /hana/data,/hana/log#/hana/shared#/usr/sap#/hana/backup)
  EOF
}

variable "pi_cloud_instance_id" {
  description = "The GUID of the service instance associated with an account."
  default     = ""
}

variable "pi_key_pair_name" {
  description = "The name of the SSH key that you want to use to access your Power Systems Virtual Server instance. The SSH key must be uploaded to IBM Cloud."
  default     = ""
}

variable "pi_sys_type" {
  description = "The type of system on which to create the VM."
  default     = ""
}


variable "pi_network_ids" {
description = "The list of network IDs that you want to assign to the instance."
type        = list(string)
default     = []
}

variable "public_pi_network_names" {
  description = "The list of public network names that you want to assign to an instance."
  type        = list(string)
  default     = []
}

variable "private_pi_network_names" {
  description = "The list of private network names that you want to assign to an instance.  If bastion_enabled = true then private_pi_network_ids cannot be blank."
  type        = list(string)
  default     = []
}
