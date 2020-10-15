variable "common_variables" {
  description = "Output of the common_variables module"
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

variable "sec_group_id" {
  type = string
}

variable "storage_account" {
  type = string
}

variable "admin_user" {
  type    = string
  default = "azadmin"
}

variable "network_domain" {
  type    = string
  default = "tf.local"
}

variable "bastion_enabled" {
  description = "Use a bastion machine to create the ssh connections"
  type        = bool
  default     = true
}

variable "bastion_host" {
  description = "Bastion host address"
  type        = string
  default     = ""
}

variable "bastion_private_key" {
  description = "Path to a SSH private key used to connect to the bastion. It must be provided if bastion is enabled"
  type        = string
  default     = ""
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

variable "netweaver_sid" {
  description = "System identifier of the Netweaver installation (e.g.: HA1 or PRD)"
  type        = string
  default     = "HA1"
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

variable "netweaver_product_id" {
  description = "Netweaver installation product. Even though the module is about Netweaver, it can be used to install other SAP instances like S4/HANA"
  type        = string
  default     = "NW750.HDB.ABAPHA"
}

variable "netweaver_inst_folder" {
  description = "Folder where SAP Netweaver installation files are mounted"
  type        = string
  default     = "/sapmedia/NW"
}

variable "netweaver_extract_dir" {
  description = "Extraction path for Netweaver media archives of SWPM and netweaver additional dvds"
  type        = string
  default     = "/sapmedia_extract/NW"
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

variable "hana_ip" {
  type        = string
  description = "Ip address of the hana database"
}

variable "ha_enabled" {
  description = "Enable HA cluster in top of Netweaver ASCS and ERS instances"
  type        = bool
  default     = true
}

variable "fencing_mechanism" {
  description = "Choose the fencing mechanism for the cluster. Options: sbd"
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
