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

variable "network_subnet_netapp_id" {
  type = string
}

variable "storage_account" {
  type = string
}

variable "hana_count" {
  type    = string
  default = "2"
}

variable "hana_instance_number" {
  description = "Instance number of the HANA system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
}

variable "storage_account_name" {
  description = "Azure storage account where SAP hana installation files are stored"
  type        = string
}

variable "storage_account_key" {
  description = "Azure storage account access key"
  type        = string
}

variable "enable_accelerated_networking" {
  type = bool
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "sles4sap_uri" {
  type    = string
  default = ""
}

variable "os_image" {
  description = "sles4sap image used to create this module machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "vm_size" {
  type    = string
  default = "Standard_E4s_v3"
}

variable "network_domain" {
  description = "hostname's network domain"
  type        = string
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

variable "hana_data_disks_configuration" {
  type        = map(any)
  default     = {}
  description = <<EOF
    This map describes how the disks will be formatted to create the definitive configuration during the provisioning.

    disks_type, disks_size, caching and writeaccelerator are used during the disks creation.
    "," is used to separate each disk.

    disk_type = The disk type used to create disks. See https://docs.microsoft.com/en-us/azure/virtual-machines/disks-enable-ultra-ssd and https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk for reference.
    disk_size = The disk size in GB.
    caching   = Sets the disk caching (None, ReadOnly, ReadWrite).
    writeaccelerator = Enable Write Accelerator (false/true, depends on disk_type).

    "#" character is used to split the volume groups, while "," is used to define the logical volumes for each group
    The number of groups split by "#" must match in all of the entries.

    luns  -> The luns or disks used for each volume group. The number of luns must match with the configured in the previous disks variables. Striped logical volumes will be created for each volume group split by "#" (example 0,1#2,3#4#5#6).
    names -> The names of the volume groups (example data#log#shared#usrsap#backup)
    sizes -> The size dedicated for each logical volume and folder (example 50#50#100#100#100)
    paths -> Folder where each volume group will be mounted (example /hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup)
  EOF
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

variable "anf_account_name" {
  description = "Name of ANF Accounts"
  type        = string
}

variable "anf_pool_name" {
  description = "Name if ANF Pool"
  type        = string
}

variable "anf_pool_service_level" {
  description = "service level for ANF shared Storage"
  type        = string
  validation {
    condition = (
      can(regex("^(Standard|Premium|Ultra)$", var.anf_pool_service_level))
    )
    error_message = "Invalid ANF Pool service level. Options: Standard|Premium|Ultra."
  }
}

variable "hana_scale_out_anf_quota_data" {
  description = "Quota for ANF shared storage volume HANA scale-out data"
  type        = number
}

variable "hana_scale_out_anf_quota_log" {
  description = "Quota for ANF shared storage volume HANA scale-out log"
  type        = number
}

variable "hana_scale_out_anf_quota_backup" {
  description = "Quota for ANF shared storage volume HANA scale-out backup"
  type        = number
}

variable "hana_scale_out_anf_quota_shared" {
  description = "Quota for ANF shared storage volume HANA scale-out shared"
  type        = number
}

variable "majority_maker_vm_size" {
  type = string
}

variable "majority_maker_ip" {
  description = "Majority Maker server address"
  type        = string
}
