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

variable "network_domain" {
  type    = string
  default = "tf.local"
}

variable "fencing_mechanism" {
  description = "Choose the fencing mechanism for the cluster. Options: sbd, native"
  type        = string
}

variable "xscs_server_count" {
  type    = number
  default = 2
}

variable "app_server_count" {
  type    = number
  default = 2
}

variable "xscs_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "app_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "data_disk_type" {
  type    = string
  default = "Premium_LRS"
}

variable "data_disk_size" {
  description = "Size of the Netweaver data disks, informed in GB"
  type        = string
  default     = "128"
}

variable "data_disk_caching" {
  type    = string
  default = "ReadWrite"
}

variable "ascs_instance_number" {
  description = "ASCS instance number"
  type        = string
}

variable "ers_instance_number" {
  description = "ERS instance number"
  type        = string
}

variable "storage_account_name" {
  description = "Azure storage account where SAP Netweaver installation files are stored"
  type        = string
}

variable "storage_account_key" {
  description = "Azure storage account access key"
  type        = string
}

variable "storage_account_path" {
  description = "Azure storage account path where SAP Netweaver installation files are stored"
  type        = string
}

variable "xscs_accelerated_networking" {
  description = "Enable accelerated networking for netweaver xSCS machines"
  type        = bool
  default     = false
}

variable "app_accelerated_networking" {
  description = "Enable accelerated networking for netweaver application server machines"
  type        = bool
  default     = false
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
  default     = ["10.74.1.30", "10.74.1.31", "10.74.1.32", "10.74.1.33"]
}

variable "virtual_host_ips" {
  description = "virtual ip addresses to set to the nodes"
  type        = list(string)
  default     = ["10.74.1.35", "10.74.1.36", "10.74.1.37", "10.74.1.38"]
}

variable "netweaver_image_uri" {
  type    = string
  default = ""
}

variable "os_image" {
  description = "sles4sap image used to create this module machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
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
  description = <<EOF
    This map describes how the disks will be formatted to create the definitive configuration during the provisioning.
  EOF
}

variable "drbd_cluster_vip" {
  description = "Virtual ip for the drbd cluster. If it's not set the address will be auto generated from the provided vnet address range"
  type        = string
}

variable "netweaver_shared_storage_type" {
  description = "Storage type to use for Netweaver deployment"
  type        = string
}
