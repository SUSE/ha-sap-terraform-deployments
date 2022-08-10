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

variable "userdata" {
  description = "userdata to inject into instance"
  type        = string
}

variable "hana_count" {
  description = "number of hosts like this one"
  default     = 2
}

variable "block_devices" {
  description = "List of devices that will be available inside the machines. These values are mapped later to hana_data_disks_configuration['devices']."
  type        = string
}

variable "hana_data_disks_configuration" {
  type        = map(any)
  description = <<EOF
    This map describes how the disks will be formatted to create the definitive configuration during the provisioning.

    disks_size is used during the disks creation. The number of elements must match in all of them
    "," is used to separate each disk.

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

variable "scale_out_nfs" {
  description = "This defines the base mountpoint on the NFS server for /hana/* and its sub directories in scale-out scenarios. It can be e.g. on the DRBD cluster (like for NetWeaver) or any other NFS share."
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
  default     = 512
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default     = 1
}

variable "majority_maker_node_vcpu" {
  description = "Number of CPUs for the HANA machines"
  type        = number
}

variable "majority_maker_node_memory" {
  description = "Memory (in MBs) for the HANA machines"
  type        = number
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

variable "storage_pool" {
  description = "libvirt storage pool name for VM disks"
  default     = "default"
}

variable "network_name" {
  description = "libvirt NAT network name for VMs, use empty string for bridged networking"
  default     = ""
}

variable "bridge" {
  description = "a bridge device name available on the libvirt host, leave default for NAT"
  default     = ""
}
