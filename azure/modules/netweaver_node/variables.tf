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

variable "sec_group_id" {
  type = string
}

variable "storage_account" {
  type = string
}

variable "netweaver_count" {
  type    = string
  default = "2"
}

variable "vm_size" {
  type    = string
  default = "Standard_D4s_v3"
}

variable "data_disk_type" {
  type    = string
  default = "Standard_LRS"
}

variable "data_disk_size" {
  description = "Size of the Netweaver data disks, informed in GB"
  type        = string
  default     = "60"
}

variable "data_disk_caching" {
  type    = string
  default = "ReadWrite"
}

variable "ascs_instance_number" {
  description = "ASCS instance number"
  type        = string
  default     = "00"
}

variable "ers_instance_number" {
  description = "ERS instance number"
  type        = string
  default     = "10"
}

variable "pas_instance_number" {
  description = "PAS instance number"
  type        = string
  default     = "01"
}

variable "aas_instance_number" {
  description = "AAS instance number"
  type        = string
  default     = "02"
}

variable "netweaver_product_id" {
  description = "Netweaver installation product. Even though the module is about Netweaver, it can be used to install other SAP instances like S4/HANA"
  type        = string
  default     = "NW750.HDB.ABAPHA"
}

variable "netweaver_swpm_folder" {
  description = "Netweaver software SWPM folder, path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_sapcar_exe" {
  description = "Path to sapcar executable, relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_swpm_sar" {
  description = "SWPM installer sar archive containing the installer, path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_swpm_extract_dir" {
  description = "Extraction path for Netweaver software SWPM folder, if SWPM sar file is provided"
  type        = string
  default     = "/sapmedia/NW/SWPM"
}

variable "netweaver_sapexe_folder" {
  description = "Software folder where needed sapexe `SAR` executables are stored (sapexe, sapexedb, saphostagent), path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_additional_dvds" {
  description = "Software folder with additional SAP software needed to install netweaver (NW export folder and HANA HDB client for example), path relative from the `netweaver_inst_media` mounted point"
  type        = list
  default     = []
}

variable "netweaver_nfs_share" {
  description = "URL of the NFS share where /sapmnt and /usr/sap/{sid}/SYS will be mounted. This folder must have the sapmnt and usrsapsys folders"
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

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking for netweaver. This function is mandatory for certified Netweaver environments and are not available for all kinds of instances. Check https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli for more details"
  type        = bool
  default     = true
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

variable "netweaver_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "netweaver_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "netweaver_public_sku" {
  type    = string
  default = "15"
}

variable "netweaver_public_version" {
  type    = string
  default = "latest"
}

variable "hana_ip" {
  type        = string
  description = "Ip address of the hana database"
}

variable "admin_user" {
  type    = string
  default = "azadmin"
}

variable "network_domain" {
  type    = string
  default = "tf.local"
}

variable "public_key_location" {
  type = string
}

variable "private_key_location" {
  type = string
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

variable "devel_mode" {
  description = "Whether or not to install the HA/SAP packages from the `ha_sap_deployment_repo`"
  type        = bool
  default     = false
}

variable "qa_mode" {
  description = "Whether or not to install the HA/SAP packages from the `ha_sap_deployment_repo`"
  type        = bool
  default     = false
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  type        = bool
  default     = false
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}
