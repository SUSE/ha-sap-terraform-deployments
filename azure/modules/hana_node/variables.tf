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

variable "name" {
  type        = string
  default     = "hana"
}

variable "ninstances" {
  type    = string
  default = "2"
}

variable "hana_count" {
  type    = string
  default = "2"
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
}

variable "reg_code" {
  description = "If informed, register the product using SUSEConnect"
  default     = ""
}

variable "reg_email" {
  description = "Email used for the registration"
  default     = ""
}

variable "reg_additional_modules" {
  description = "Map of the modules to be registered. Module name = Regcode, when needed."
  type        = map(string)
  default     = {}
}

variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages"
  type        = string
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "instancetype" {
  type    = string
}

variable "data_disk_type" {
  type    = string
  default = "Standard_LRS"
}

variable "data_disk_size" {
  description = "Size of the hana data disks, informed in GB"
  type    = string
  default = "60"
}

variable "sec_group_id" {
  type = string
}

variable "enable_accelerated_networking" {
 type        = bool
}

variable "storage_account_name" {
  description = "Azure storage account where SAP hana installation files are stored"
  type        = string
}

variable "storage_account_key" {
  description = "Azure storage account access key"
  type        = string
}

variable "sles4sap_uri" {
  type    = string
  default = ""
}

variable "init_type" {
  type    = string
  default = "all"
}

variable "hana_inst_master" {
  type = string
}

variable "hana_inst_folder" {
  type    = string
  default = "/root/hana_inst_media"
}

variable "hana_disk_device" {
  description = "device where to install HANA"
  type        = string
}

variable "hana_fstype" {
  description = "Filesystem type to use for HANA"
  type        = string
  default     = "xfs"
}

variable "cluster_ssh_pub" {
  description = "path for the public key needed by the cluster"
  type        = string
}

variable "cluster_ssh_key" {
  description = "path for the private key needed by the cluster"
  type        = string
}

variable "public_key_location" {
  type = string
}

variable "private_key_location" {
  type = string
}

variable "hana_data_disk_type" {
  type    = string
  default = "Standard_LRS"
}

variable "hana_data_disk_size" {
  type    = string
  default = "60"
}

variable "hana_data_disk_caching" {
  type    = string
}

variable "hana_public_publisher" {
  type    = string
}

variable "hana_public_offer" {
  type    = string
}

variable "hana_public_sku" {
  type    = string
}

variable "hana_public_version" {
  type    = string
}

variable "admin_user" {
  type    = string
  default = "azadmin"
}

variable "iscsi_srv_ip" {
  description = "iscsi server address"
  type        = string
}

variable "devel_mode" {
  description = "Whether or not to install the HA/SAP packages from the `ha_sap_deployment_repo`"
  default     = false
}

variable "qa_mode" {
  description = "Whether or not to install the HA/SAP packages from the `ha_sap_deployment_repo`"
  default     = false
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  default     = []
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  default     = false
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  default     = false
}

variable "hwcct" {
  description = "Execute HANA Hardware Configuration Check Tool to bench filesystems"
  type        = bool
  default     = false
}