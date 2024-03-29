variable "hana_sid" {
  description = "System identifier of the HANA system. It must be a 3 characters string (check the restrictions in the SAP documentation pages). Examples: prd, ha1"
  type        = string
  validation {
    condition = (
      can(regex("^[A-Z][A-Z0-9]{2}$", var.hana_sid))
    )
    error_message = "The HANA system identifier must be composed by 3 uppercase chars/digits string starting always with a character (there are some restricted options)."
  }
}

variable "hana_cost_optimized_sid" {
  description = "System identifier of the HANA cost-optimized system. It must be a 3 characters string (check the restrictions in the SAP documentation pages). Examples: prd, ha1"
  type        = string
  validation {
    condition = (
      can(regex("^[A-Z][A-Z0-9]{2}$", var.hana_cost_optimized_sid))
    )
    error_message = "The HANA system identifier must be composed by 3 uppercase chars/digits string starting always with a character (there are some restricted options)."
  }
}

variable "hana_instance_number" {
  description = "Instance number of the HANA system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  validation {
    condition = (
      can(regex("^[0-9]{2}$", var.hana_instance_number))
    )
    error_message = "The HANA instance number must be composed by 2 digits string."
  }
}

variable "hana_cost_optimized_instance_number" {
  description = "Instance number of the HANA cost-optimized system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  validation {
    condition = (
      can(regex("^[0-9]{2}$", var.hana_cost_optimized_instance_number))
    )
    error_message = "The HANA instance number must be composed by 2 digits string."
  }
}

# for password rules see: doc/sap_passwords.md
variable "hana_master_password" {
  description = "Master password for the HANA system (sidadm user included)"
  type        = string
  validation {
    condition = (
      can(regex("[0-9]+", var.hana_master_password)) &&
      can(regex("[a-z]+", var.hana_master_password)) &&
      can(regex("[A-Z]+", var.hana_master_password)) &&
      can(regex("^.{10,14}$", var.hana_master_password))
    )
    error_message = "The hana master password in default configuration must contain at least 8 up to 64 characters. To be compatible with our Netweaver and S/4HANA deployment we set it to 10 to 14 characters, though. It must contain at least 1 digit, 1 upper-case character, 1 lower-case character and optional special characters. For more information see: 'doc/sap_passwords.md'."
  }
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

variable "hana_inst_master" {
  description = "Shared storage path where the SAP HANA software installer is stored. This media shall be mounted in `hana_inst_folder`. Depending on cloud provider, it can be S3 bucket folder path in AWS, an Azure storage account path or a NFS share url in Libvirt "
  type        = string
}

variable "hana_inst_folder" {
  description = "Folder where SAP HANA installation files are stored"
  type        = string
}

variable "hana_fstype" {
  description = "Filesystem type used by the disk where hana is installed"
  type        = string
}

variable "hana_platform_folder" {
  description = "Path to the hana platform media, relative to the 'hana_inst_master' mounting point"
  type        = string
}

variable "hana_sapcar_exe" {
  description = "Path to the sapcar executable, relative to the 'hana_inst_master' mounting point"
  type        = string
}

variable "hana_archive_file" {
  description = "Path to the HANA database server installation SAR archive or HANA platform archive file in zip or rar format, relative to the 'hana_inst_master' mounting point. Use this parameter if the hana media archive is not already extracted"
  type        = string
}

variable "hana_extract_dir" {
  description = "Absolute path to folder where SAP HANA archive will be extracted"
  type        = string
}

variable "hana_client_folder" {
  description = "Path to the extracted HANA Client folder, relative to the 'hana_inst_master' mounting point"
  type        = string
}

variable "hana_client_archive_file" {
  description = "Path to the HANA Client SAR archive , relative to the 'hana_inst_master' mounting point. Use this parameter if the HANA Client archive is not already extracted"
  type        = string
}

variable "hana_client_extract_dir" {
  description = "Absolute path to folder where SAP HANA Client archive will be extracted"
  type        = string
}

variable "hana_scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  type        = string
  validation {
    condition = (
      can(regex("^(performance-optimized|cost-optimized)$", var.hana_scenario_type))
    )
    error_message = "Invalid HANA scenario type. Options: performance-optimized|cost-optimized ."
  }
}

variable "hana_cluster_vip_mechanism" {
  description = "Mechanism used to manage the virtual IP address in the hana cluster."
  type        = string
}

variable "hana_cluster_vip" {
  description = "IP address used to configure the hana cluster floating IP. It must be in other subnet than the machines!"
  type        = string
}

variable "hana_cluster_vip_secondary" {
  description = "IP address used to configure the hana cluster floating IP for the secondary node in an Active/Active mode"
  type        = string
}

variable "hana_hwcct" {
  description = "Execute HANA Hardware Configuration Check Tool to bench filesystems"
  type        = bool
  default     = false
}

variable "hana_ha_enabled" {
  description = "Enable HA cluster in top of HANA system replication"
  type        = bool
}

variable "hana_extra_parameters" {
  type        = map(any)
  description = <<EOF
    This map allows to add any extra parameters to the HANA installation.

    Have a look at the Parameter Reference:
    https://help.sap.com/docs/SAP_HANA_PLATFORM/2c1988d620e04368aa4103bf26f17727/c16432a77b6144dcb75aace2b4fcacff.html

    hana_extra_parameters = {
      ignore = "check_min_mem,check_version",
      install_execution_mode = "optimized"
    }
  EOF
}

variable "hana_cluster_fencing_mechanism" {
  description = "Select the HANA cluster fencing mechanism. Options: sbd"
  type        = string
}

variable "hana_sbd_storage_type" {
  description = "Choose the SBD storage type. Options: iscsi, shared-disk(this option available in Libvirt only)"
  type        = string
}

variable "hana_scale_out_enabled" {
  description = "Enable HANA scale out deployment"
  type        = bool
}

variable "hana_scale_out_shared_storage_type" {
  description = "Storage type to use for HANA scale out deployment"
  type        = string
  validation {
    condition = (
      can(regex("^(|anf|efs|filestore|nfs)$", var.hana_scale_out_shared_storage_type))
    )
    error_message = "Invalid HANA scale out storage type. Options: anf, efs, filestore, nfs."
  }
}

variable "hana_scale_out_addhosts" {
  type        = map(any)
  description = <<EOF
    Additional hosts to pass to HANA scale-out installation
  EOF
}

variable "hana_scale_out_standby_count" {
  description = "Number of HANA scale-out standby nodes to be deployed per site"
  type        = number
}

variable "hana_basepath_shared" {
  description = "Set persistence.basepath_shared in global.ini (SAP Note 2080991)."
  type        = bool
  default     = true
}

variable "hana_ha_dr_sustkover_enabled" {
  description = "enable susTkOver hook"
  type        = bool
}

variable "hana_ha_dr_suschksrv_enabled" {
  description = "enable susChkSrv hook"
  type        = bool
}

variable "hana_ha_dr_suschksrv_action_on_lost" {
  description = "define action on lost for susChkSrv, see `man 7 susChkSrv.py`"
  type        = string
  validation {
    condition = (
      can(regex("^(stop|fence)$", var.hana_ha_dr_suschksrv_action_on_lost))
    )
    error_message = "Invalid action on lost for susChkrSrv. Options: stop, fence."
  }
}
