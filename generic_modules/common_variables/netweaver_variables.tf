variable "netweaver_ha_enabled" {
  description = "Enable HA cluster in top of Netweaver ASCS and ERS instances"
  type        = bool
}

variable "netweaver_cluster_fencing_mechanism" {
  description = "Choose the fencing mechanism for the cluster. Options: sbd, native"
  type        = string
}

variable "netweaver_sbd_storage_type" {
  description = "Choose the SBD storage type. Options: iscsi"
  type        = string
}

variable "netweaver_sid" {
  description = "System identifier of the Netweaver installation (e.g.: HA1 or PRD)"
  type        = string
}

variable "netweaver_ascs_instance_number" {
  description = "ASCS instance number"
  type        = string
}

variable "netweaver_ers_instance_number" {
  description = "ERS instance number"
  type        = string
}

variable "netweaver_pas_instance_number" {
  description = "PAS instance number"
  type        = string
}

variable "netweaver_master_password" {
  description = "Master password for the Netweaver system (sidadm user included)"
  type        = string
}

variable "netweaver_product_id" {
  description = "Netweaver installation product. Even though the module is about Netweaver, it can be used to install other SAP instances like S4/HANA"
  type        = string
}

variable "netweaver_inst_folder" {
  description = "Folder where SAP Netweaver installation files are mounted"
  type        = string
}

variable "netweaver_extract_dir" {
  description = "Extraction path for Netweaver media archives of SWPM and netweaver additional dvds"
  type        = string
}

variable "netweaver_swpm_folder" {
  description = "Netweaver software SWPM folder, path relative from the `netweaver_inst_media` mounted point"
  type        = string
}

variable "netweaver_sapcar_exe" {
  description = "Path to sapcar executable, relative from the `netweaver_inst_media` mounted point"
  type        = string
}

variable "netweaver_swpm_sar" {
  description = "SWPM installer sar archive containing the installer, path relative from the `netweaver_inst_media` mounted point"
  type        = string
}

variable "netweaver_sapexe_folder" {
  description = "Software folder where needed sapexe `SAR` executables are stored (sapexe, sapexedb, saphostagent), path relative from the `netweaver_inst_media` mounted point"
  type        = string
}

variable "netweaver_additional_dvds" {
  description = "Software folder with additional SAP software needed to install netweaver (NW export folder and HANA HDB client for example), path relative from the `netweaver_inst_media` mounted point"
  type        = list
}

variable "netweaver_nfs_share" {
  description = "URL of the NFS share where /sapmnt and /usr/sap/{sid}/SYS will be mounted. This folder must have the sapmnt and usrsapsys folders"
  type        = string
}

variable "netweaver_sapmnt_path" {
  description = "Path where sapmnt folder is stored"
  type        = string
}

variable "netweaver_hana_ip" {
  description = "IP address of the HANA database. If the database is clustered, use the cluster virtual ip address"
  type        = string
}

variable "netweaver_hana_sid" {
  description = "System identifier of the HANA system (e.g.: HA1 or PRD)"
  type        = string
}

variable "netweaver_hana_instance_number" {
  description = "Instance number of the HANA system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
}

variable "netweaver_hana_master_password" {
  description = "Master password for the HANA system (sidadm user included)"
  type        = string
}
