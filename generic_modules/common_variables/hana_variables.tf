# HANA related variables used to render the HANA pillar data

variable "hana_sid" {
  description = "System identifier of the HANA system. It must be a 3 characters string (check the restrictions in the SAP documentation pages). Examples: prd, ha1"
  type        = string
}

variable "hana_cost_optimized_sid" {
  description = "System identifier of the HANA cost-optimized system. It must be a 3 characters string (check the restrictions in the SAP documentation pages). Examples: prd, ha1"
  type        = string
}

variable "hana_instance_number" {
  description = "Instance number of the HANA system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
}

variable "hana_cost_optimized_instance_number" {
  description = "Instance number of the HANA cost-optimized system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
}

variable "hana_master_password" {
  description = "Master password for the HANA system (sidadm user included)"
  type        = string
}

variable "hana_cost_optimized_master_password" {
  description = "Master password for the HANA system (sidadm user included)"
  type        = string
}

variable "hana_primary_site" {
  description = "HANA system replication primary site name"
  type        = string
}

variable "hana_secondary_site" {
  description = "HANA system replication secondary site name"
  type        = string
}

variable "hana_cluster_vip" {
  description = "IP address used to configure the hana cluster floating IP"
  type        = string
}

variable "hana_cluster_vip_secondary" {
  description = "IP address used to configure the hana cluster floating IP for the secondary node in an Active/Active mode"
  type        = string
  default     = ""
}

variable "hana_inst_folder" {
  description = "Folder where SAP HANA installation files are stored"
  type        = string
}

variable "hana_platform_folder" {
  description = "Path to the hana platform media, relative to the 'hana_inst_media' mounting point"
  type        = string
  default     = ""
}

variable "hana_sapcar_exe" {
  description = "Path to the sapcar executable, relative to the 'hana_inst_media' mounting point"
  type        = string
  default     = ""
}

variable "hana_archive_file" {
  description = "Path to the HANA database server installation SAR archive or HANA platform archive file in zip or rar format, relative to the 'hana_inst_master' mounting point. Use this parameter if the hana media archive is not already extracted"
  type        = string
  default     = ""
}

variable "hana_extract_dir" {
  description = "Absolute path to folder where SAP HANA archive will be extracted"
  type        = string
  default     = "/sapmedia/HANA"
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
}
