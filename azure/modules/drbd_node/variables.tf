variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "bastion_host" {
  description = "Bastion host address"
  type        = string
  default     = ""
}

variable "az_region" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type = string
}

variable "network_subnet_id" {
  type = string
}

variable "storage_account" {
  type = string
}

variable "drbd_count" {
  type    = string
  default = "2"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "drbd"
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
  default     = ["10.74.1.20", "10.74.1.21"]
}

variable "drbd_image_uri" {
  type    = string
  default = ""
}

variable "os_image" {
  description = "sles4sap image used to create this module machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "network_domain" {
  type    = string
  default = "tf.local"
}

variable "fencing_mechanism" {
  description = "Choose the fencing mechanism for the cluster. Options: sbd, native"
  type        = string
}

variable "sbd_storage_type" {
  description = "Choose the SBD storage type. Options: iscsi"
  type        = string
  default     = "iscsi"
}

variable "iscsi_srv_ip" {
  description = "iscsi server address"
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

variable "nfs_mounting_point_netweaver" {
  description = "Mounting point of the Netweaver NFS shares created in to of DRBD (`/mnt` must not be used in Azure)"
  type        = string
}

variable "nfs_mounting_point_hana" {
  description = "Mounting point of the HANA NFS shares created in to of DRBD (`/mnt` must not be used in Azure)"
  type        = string
}

variable "nfs_export_name" {
  description = "Name of the created export in the NFS service. Usually, the `sid` of the SAP instances is used"
  type        = string
}

variable "subscription_id" {
  description = "ID of the azure subscription."
  type        = string
}

variable "tenant_id" {
  description = "ID of the azure tenant."
  type        = string
}

variable "fence_agent_app_id" {
  description = "ID of the azure service principal / application that is used for native fencing."
  type        = string
}

variable "fence_agent_client_secret" {
  description = "Secret for the azure service principal / application that is used for native fencing."
  type        = string
}

variable "drbd_data_disks_configuration_netweaver" {
  type = map
  default = {
    disks_type       = "Premium_LRS"
    disks_size       = "10"
    caching          = "None"
    writeaccelerator = "false"
    # The next variables are used during the provisioning
    luns     = "0"
    names    = "sapdata"
    lv_sizes = "10"
    nfs_paths    = "/mnt_permanent/sapdata" # use same as in drbd_nfs_mounting_point_netweaver
  }
  description = <<EOF
    This map describes how the disks will be formatted to create the definitive configuration during the provisioning.
    disks_type, disks_size, caching and writeaccelerator are used during the disks creation. The number of elements must match in all of them
    "#" character is used to split the volume groups, while "," is used to define the logical volumes for each group
    The number of groups split by "#" must match in all of the entries
    names -> The names of the volume groups (example datalog#shared#usrsap#backup#sapmnt)
    luns  -> The luns or disks used for each volume group. The number of luns must match with the configured in the previous disks variables (example 0,1,2#3#4#5#6)
    sizes -> The size dedicated for each logical volume and folder (example 70,100#100#100#100#100)
    nfs_paths -> Folder where each volume group will be mounted (example /hana/data,/hana/log#/hana/shared#/usr/sap#/hana/backup#/sapmnt/)
  EOF
}

variable "drbd_data_disks_configuration_hana" {
  type = map
  default = {
    disks_type       = "Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS"
    disks_size       = "128,128,128,128,128"
    caching          = "None,None,None,None,None"
    writeaccelerator = "false,false,false,false,false"
    # The next variables are used during the provisioning
    luns     = "1,2#3,4#5"
    names    = "data#log#backup"
    lv_sizes = "100#100#100"
    nfs_paths    = "/mnt_permanent/hana/data#/mnt_permanent/hana/log#/mnt_permanent/hana/backup" # use same as in drbd_nfs_mounting_point_hana
    mount_paths    = "/hana/data#/hana/log#/hana/backup" # use same as in drbd_nfs_mounting_point_hana
  }
  description = <<EOF
    This map describes how the disks will be formatted to create the definitive configuration during the provisioning.
    disks_type, disks_size, caching and writeaccelerator are used during the disks creation. The number of elements must match in all of them
    "#" character is used to split the volume groups, while "," is used to define the logical volumes for each group
    The number of groups split by "#" must match in all of the entries
    names -> The names of the volume groups (example datalog#shared#usrsap#backup#sapmnt)
    luns  -> The luns or disks used for each volume group. The number of luns must match with the configured in the previous disks variables (example 0,1,2#3#4#5#6)
    sizes -> The size dedicated for each logical volume and folder (example 70,100#100#100#100#100)
    nfs_paths -> Folder where each volume group will be mounted (example /hana/data,/hana/log#/hana/shared#/usr/sap#/hana/backup#/sapmnt/)
    mount_paths -> Folder where each volume group will be mounted (example /hana/data,/hana/log#/hana/shared#/usr/sap#/hana/backup#/sapmnt/)
  EOF
}

variable "drbd_cluster_vip" {
  description = "Virtual ip for the drbd cluster. If it's not set the address will be auto generated from the provided vnet address range"
  type        = string
}
