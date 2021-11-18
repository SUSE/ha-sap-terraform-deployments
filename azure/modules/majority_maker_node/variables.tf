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

variable "storage_account_name" {
  description = "Azure storage account where SAP hana installation files are stored"
  type        = string
}

variable "storage_account_key" {
  description = "Azure storage account access key"
  type        = string
}

variable "hana_count" {
  type = string
}

variable "name" {
  type = string
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

variable "node_count" {
  type = number
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "majority_maker_ip" {
  description = "Majority Maker server address"
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
