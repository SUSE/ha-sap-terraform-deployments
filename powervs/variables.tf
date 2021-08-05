## IBM Cloud related variables
# https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-provider-reference#required-parameters

variable "ibmcloud_api_key" {
  description = "The IBM Cloud API key to authenticate with the IBM Cloud platform."
  default     = ""
}

variable "region" {
  description = "The IBM Cloud API key to authenticate with the IBM Cloud platform."
  default     = "eu-de"
}

variable "zone" {
  description = "The IBM Cloud API key to authenticate with the IBM Cloud platform."
  default     = "eu-de-1"
}

## IBM PowerVS related variables
# https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-power-vsi&locale=en

variable "pi_cloud_instance_id" {
  description = "The GUID of the service instance associated with an account."
  type        = string
}

variable "pi_key_pair_name" {
  description = "The name of the SSH key that you want to use to access your Power Systems Virtual Server instance."
  type        = string
}

variable "pi_sys_type" {
  description = "The type of system on which to create the LPAR."
  default     = ""
}

variable "public_pi_network_ids" {
  description = "The list of public network IDs that you want to assign to an instance."
  type        = list(string)
  default     = []
}

variable "public_pi_network_names" {
  description = "The list of public network names that you want to assign to an instance."
  type        = list(string)
  default     = []
}

variable "private_pi_network_ids" {
  description = "The list of private network IDs that you want to assign to an instance.  If bastion_enabled = true then private_pi_network_ids cannot be blank."
  type        = list(string)
  default     = []
}

variable "private_pi_network_names" {
  description = "The list of private network names that you want to assign to an instance.  If bastion_enabled = true then private_pi_network_ids cannot be blank."
  type        = list(string)
  default     = []
}

variable "bastion_enabled" {
  description = "Create a VM to work as a bastion to avoid the usage of public ip addresses and manage the ssh connection to the other machines"
  type        = bool
  default     = true
}

variable "bastion_os_image" {
  description = "sles4sap image used to create the bastion machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
  default     = ""
}

variable "bastion_public_key" {
  description = "Content of a SSH public key or path to an already existing SSH public key to the bastion. If it's not set the key provided in public_key will be used"
  type        = string
  default     = ""
}

variable "bastion_private_key" {
  description = "Content of a SSH private key or path to an already existing SSH private key to the bastion. If it's not set the key provided in private_key will be used"
  type        = string
  default     = ""
}

variable "bastion_enabled_node_vcpu" {
  description = "Number of CPUs for the bastion machines"
  type        = number
  default     = 2
}

variable "bastion_node_vcpu" {
  description = "Number of CPUs for the bastion machine"
  type        = number
  default     = 2
}

variable "bastion_node_memory" {
  description = "Memory (in GBs) for the bastion machines"
  type        = number
  default     = 8
}

## Deployment variables

variable "deployment_name" {
  description = "Suffix string added to some of the infrastructure resources names. If it is not provided, the terraform workspace string is used as prefix"
  type        = string
  default     = ""
}

variable "os_image" {
  description = "Default OS image for all the machines. This value is not used if the specific nodes os_image is set (e.g. hana_os_image)"
  type        = string
  default     = ""
}

variable "admin_user" {
  description = "Administration user used to create the machines"
  type        = string
}

variable "private_key" {
  description = "Content of a SSH private key or path to an already existing SSH private key. The key is only used to provision the machines. It is not uploaded to the machines in any case"
  type        = string
}

variable "cluster_ssh_pub" {
  description = "Path to a SSH public key used during the cluster creation. The key must be passwordless"
  type        = string
}

variable "cluster_ssh_key" {
  description = "Path to a SSH private key used during the cluster creation. The key must be passwordless"
  type        = string
}

variable "reg_code" {
  description = "If informed, register the product using SUSEConnect"
  type        = string
  default     = ""
}

variable "reg_email" {
  description = "Email used for the registration"
  default     = ""
}

# The module format must follow SUSEConnect convention:
# <module_name>/<product_version>/<architecture>
# Example: Suggested modules for SLES for SAP 15
# - sle-module-basesystem/15/x86_64
# - sle-module-desktop-applications/15/x86_64
# - sle-module-server-applications/15/x86_64
# - sle-ha/15/x86_64 (Need the same regcode as SLES for SAP)
# - sle-module-sap-applications/15/x86_64

variable "reg_additional_modules" {
  description = "Map of the modules to be registered. Module name = Regcode, when needed."
  type        = map(string)
  default     = {}
}

variable "additional_packages" {
  description = "Extra packages to be installed"
  default     = []
}

# Repository url used to install development versions of HA/SAP deployment packages
# The latest RPM packages can be found at:
# https://download.opensuse.org/repositories/network:ha-clustering:sap-deployments:devel/{YOUR SLE VERSION}
# Contains the salt formulas rpm packages.
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install development versions of HA/SAP deployment packages. If the SLE version is not present in the URL, it will be automatically detected"
  type        = string
  default     = ""
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "provisioning_log_level" {
  description = "Provisioning process log level. For salt: https://docs.saltstack.com/en/latest/ref/configuration/logging/index.html"
  type        = string
  default     = "error"
}

variable "provisioning_output_colored" {
  description = "Print colored output of the provisioning execution"
  type        = bool
  default     = true
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  type        = bool
  default     = false
}

## HANA related variables

variable "name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "hana"
}

variable "hana_os_image" {
  description = "sles4sap image used to create the HANA machines."
  type        = string
  default     = ""
}

variable "hana_count" {
  description = "Number of hana nodes"
  type        = string
  default     = "2"
}

variable "hana_node_vcpu" {
  description = "Number of CPUs for the HANA machines"
  type        = number
  default     = 4
}

variable "hana_node_memory" {
  description = "Memory (in GBs) for the HANA machines"
  type        = number
  default     = 32
}

variable "hana_data_disks_configuration" {
  type = map
  default = {
    disks_type       = "tier1,tier1,tier1,tier1,tier1,tier1,tier1"
    disks_size       = "128,128,128,128,128,128,128"
    # The next variables are used during the provisioning
    luns     = "0,1#2,3#4#5#6"
    names    = "data#log#shared#usrsap#backup"
    lv_sizes = "100#100#100#100#100"
    paths    = "/hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup"
  }
  description = <<EOF
  This map describes how the disks will be formatted to create the definitive configuration during the provisioning.
  disks_per_instance, disks_type, disks_size are used during the disks creation. The number of disks much match number of luns.
  "#" character is used to split the volume groups, while "," is used to define the logical volumes for each group
  The number of groups split by "#" must match the number of disks.
  names -> The names of the volume groups (example datalog#shared#usrsap#backup)
  luns  -> The luns or disks used for each volume group. The number of luns must match with the configured in the previous disks variables (example 0,1,2#3#4#5)
  sizes -> The size dedicated for each logical volume and folder (example 70,100#100#100#100)
  paths -> Folder where each volume group will be mounted (example /hana/data,/hana/log#/hana/shared#/usr/sap#/hana/backup)
  EOF
}

variable "hana_ips" {
  description = "ip addresses to set to the hana nodes. If it's not set the addresses will be auto generated from the provided vnet address range"
  type        = list(string)
  default     = []
}

variable "hana_inst_master" {
  description = "Azure storage account path where hana installation software is available"
  type        = string
}

variable "hana_inst_folder" {
  description = "Folder where the hana installation software will be downloaded"
  type        = string
  default     = "/sapmedia/HANA"
}

variable "hana_platform_folder" {
  description = "Path to the hana platform media, relative to the 'hana_inst_master' mounting point"
  type        = string
  default     = ""
}

variable "hana_sapcar_exe" {
  description = "Path to the sapcar executable, relative to the 'hana_inst_master' mounting point. Only needed if HANA installation software comes in a SAR file (like IMDB_SERVER.SAR)"
  type        = string
  default     = ""
}

variable "hana_archive_file" {
  description = "Path to the HANA database server installation SAR archive (for SAR files, `hana_sapcar_exe` variable is mandatory) or HANA platform archive file in ZIP or RAR (EXE) format, relative to the 'hana_inst_master' mounting point. Use this parameter if the HANA media archive is not already extracted"
  type        = string
  default     = ""
}

variable "hana_extract_dir" {
  description = "Absolute path to folder where SAP HANA archive will be extracted. This folder cannot be the same as `hana_inst_folder`!"
  type        = string
  default     = "/sapmedia_extract/HANA"
}

variable "hana_client_folder" {
  description = "Path to the extracted HANA Client folder, relative to the 'hana_inst_master' mounting point"
  type        = string
  default     = ""
}

variable "hana_client_archive_file" {
  description = "Path to the HANA Client SAR archive , relative to the 'hana_inst_master' mounting point. Use this parameter if the HANA Client archive is not already extracted"
  type        = string
  default     = ""
}

variable "hana_client_extract_dir" {
  description = "Absolute path to folder where SAP HANA Client archive will be extracted"
  type        = string
  default     = "/sapmedia_extract/HANA_CLIENT"
}

variable "hana_fstype" {
  description = "Filesystem type used by the disk where hana is installed"
  type        = string
  default     = "xfs"
}

variable "hana_sid" {
  description = "System identifier of the HANA system. It must be a 3 characters string (check the restrictions in the SAP documentation pages). Examples: prd, ha1"
  type        = string
  default     = "PRD"
}

variable "hana_cost_optimized_sid" {
  description = "System identifier of the HANA cost-optimized system. It must be a 3 characters string (check the restrictions in the SAP documentation pages). Examples: prd, ha1"
  type        = string
  default     = "QAS"
}

variable "hana_instance_number" {
  description = "Instance number of the HANA system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "00"
}

variable "hana_cost_optimized_instance_number" {
  description = "Instance number of the HANA cost-optimized system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "01"
}

variable "hana_master_password" {
  description = "Master password for the HANA system (sidadm user included)"
  type        = string
}

variable "hana_cost_optimized_master_password" {
  description = "Master password for the HANA system (sidadm user included)"
  type        = string
  default     = ""
}

variable "hana_primary_site" {
  description = "HANA system replication primary site name"
  type        = string
  default     = "Site1"
}

variable "hana_secondary_site" {
  description = "HANA system replication secondary site name"
  type        = string
  default     = "Site2"
}

variable "hana_cluster_vip" {
  description = "Virtual ip for the hana cluster. If it's not set the address will be auto generated from the provided vnet address range"
  type        = string
  default     = ""
}

variable "hana_cluster_fencing_mechanism" {
  description = "Select the HANA cluster fencing mechanism. Options: sbd"
  type        = string
  default     = "sbd"
}

variable "hana_ha_enabled" {
  description = "Enable HA cluster in top of HANA system replication"
  type        = bool
  default     = true
}

variable "hana_active_active" {
  description = "Enable an Active/Active HANA system replication setup"
  type        = bool
  default     = false
}

variable "hana_cluster_vip_secondary" {
  description = "IP address used to configure the hana cluster floating IP for the secondary node in an Active/Active mode. Let empty to use an auto generated address"
  type        = string
  default     = ""
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
}

## SBD related variables
# In order to enable SBD, an ISCSI server is needed as right now is the unique option
# All the clusters will use the same mechanism

variable "sbd_storage_type" {
  description = "Choose the SBD storage type. Options: iscsi, shared-disk"
  type        = string
  default     = "shared-disk"
}

variable "sbd_disk_size" {
  description = "Disk size (in GB) for the SBD disk. It's used to create the ISCSI server disk too"
  type        = number
  default     = 1
}

# If iscsi is selected as sbd_storage_type
# Use the next variables for advanced configuration

variable "iscsi_os_image" {
  description = "sles4sap image used to create the ISCSI machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
  default     = ""
}

variable "iscsi_srv_uri" {
  description = "Path to a custom azure image in a storage account used to create the iscsi machines"
  type        = string
  default     = ""
}

variable "iscsi_vm_size" {
  description = "VM size for the iscsi server machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "iscsi_srv_ip" {
  description = "iscsi server address. If it's not set the address will be auto generated from the provided vnet address range"
  type        = string
  default     = ""
}

variable "iscsi_lun_count" {
  description = "Number of LUN (logical units) to serve with the iscsi server. Each LUN can be used as a unique sbd disk"
  default     = 3
}

## Monitoring related variables

variable "monitoring_enabled" {
  description = "Enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

variable "monitoring_vm_size" {
  description = "VM size for the monitoring machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "monitoring_os_image" {
  description = "sles4sap image used to create the Monitoring server machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
  default     = ""
}

variable "monitoring_uri" {
  description = "Path to a custom azure image in a storage account used to create the monitoring machines"
  type        = string
  default     = ""
}

variable "monitoring_srv_ip" {
  description = "monitoring server address. If it's not set the address will be auto generated from the provided vnet address range"
  type        = string
  default     = ""
}

## DRBD related variables

variable "drbd_enabled" {
  description = "Enable the DRBD cluster for nfs"
  type        = bool
  default     = false
}

variable "drbd_vm_size" {
  description = "VM size for the DRBD machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "drbd_ips" {
  description = "ip addresses to set to the drbd cluster nodes. If it's not set the addresses will be auto generated from the provided vnet address range"
  type        = list(string)
  default     = []
}

variable "drbd_os_image" {
  description = "sles4sap image used to create the DRBD machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
  default     = ""
}

variable "drbd_image_uri" {
  description = "Path to a custom azure image in a storage account used to create the drbd machines"
  type        = string
  default     = ""
}

variable "drbd_cluster_vip" {
  description = "Virtual ip for the drbd cluster. If it's not set the address will be auto generated from the provided vnet address range"
  type        = string
  default     = ""
}

variable "drbd_cluster_fencing_mechanism" {
  description = "Select the DRBD cluster fencing mechanism. Options: sbd"
  type        = string
  default     = "sbd"
}

variable "drbd_nfs_mounting_point" {
  description = "Mounting point of the NFS share created in to of DRBD (`/mnt` must not be used in Azure)"
  type        = string
  default     = "/mnt_permanent/sapdata"
}

## Netweaver related variables

variable "netweaver_enabled" {
  description = "Enable SAP Netweaver cluster deployment"
  type        = bool
  default     = false
}

variable "netweaver_app_server_count" {
  description = "Number of PAS/AAS servers (1 PAS and the rest will be AAS). 0 means that the PAS is installed in the same machines as the ASCS"
  type        = number
  default     = 2
}

variable "netweaver_os_image" {
  description = "sles4sap image used to create the Netweaver machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
  default     = ""
}

variable "netweaver_image_uri" {
  description = "Path to a custom azure image in a storage account used to create the netweaver machines"
  type        = string
  default     = ""
}

variable "netweaver_xscs_vm_size" {
  description = "VM size for the Netweaver xSCS machines"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "netweaver_app_vm_size" {
  description = "VM size for the Netweaver application servers"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "netweaver_data_disk_type" {
  description = "Disk type of the disks used to store netweaver content in the application servers"
  type        = string
  default     = "Premium_LRS"
}

variable "netweaver_data_disk_size" {
  description = "Size of the netweaver data disks in the application servers, informed in GB"
  type        = string
  default     = "128"
}

variable "netweaver_data_disk_caching" {
  description = "Disk caching of the disks used to store netweaver content in the application servers"
  type        = string
  default     = "ReadWrite"
}

variable "netweaver_xscs_accelerated_networking" {
  description = "Enable accelerated networking for netweaver xSCS machines"
  type        = bool
  default     = false
}

variable "netweaver_app_accelerated_networking" {
  description = "Enable accelerated networking for netweaver application server machines"
  type        = bool
  default     = false
}

variable "netweaver_ips" {
  description = "ip addresses to set to the netweaver cluster nodes. If it's not set the addresses will be auto generated from the provided vnet address range"
  type        = list(string)
  default     = []
}

variable "netweaver_virtual_ips" {
  description = "Virtual ip addresses to set to the netweaver cluster nodes. If it's not set the addresses will be auto generated from the provided vnet address range"
  type        = list(string)
  default     = []
}

variable "netweaver_sid" {
  description = "System identifier of the Netweaver installation (e.g.: HA1 or PRD)"
  type        = string
  default     = "HA1"
}

variable "netweaver_ascs_instance_number" {
  description = "Instance number of the ASCS system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "00"
}

variable "netweaver_ers_instance_number" {
  description = "Instance number of the ERS system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "10"
}

variable "netweaver_pas_instance_number" {
  description = "Instance number of the PAS system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "01"
}

variable "netweaver_master_password" {
  description = "Master password for the Netweaver system (sidadm user included)"
  type        = string
}

variable "netweaver_cluster_fencing_mechanism" {
  description = "Select the Netweaver cluster fencing mechanism. Options: sbd"
  type        = string
  default     = "sbd"
}

variable "netweaver_nfs_share" {
  description = "URL of the NFS share where /sapmnt and /usr/sap/{sid}/SYS will be mounted. This folder must have the sapmnt and usrsapsys folders. This parameter can be omitted if drbd_enabled is set to true, as a HA nfs share will be deployed by the project. Finally, if it is not used or set empty, these folders are created locally (for single machine deployments)"
  type        = string
  default     = ""
}

variable "netweaver_sapmnt_path" {
  description = "Path where sapmnt folder is stored"
  type        = string
  default     = "/sapmnt"
}

variable "netweaver_storage_account_name" {
  description = "Azure storage account where SAP Netweaver installation files are stored"
  type        = string
  default     = ""
}

variable "netweaver_storage_account_key" {
  description = "Azure storage account access key"
  type        = string
  default     = ""
}

variable "netweaver_storage_account" {
  description = "Azure storage account path"
  type        = string
  default     = ""
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

variable "netweaver_ha_enabled" {
  description = "Enable HA cluster in top of Netweaver ASCS and ERS instances"
  type        = bool
  default     = true
}

## Specific QA variables

variable "qa_mode" {
  description = "Enable test/qa mode (disable extra packages usage not coming in the image)"
  type        = bool
  default     = false
}

variable "hwcct" {
  description = "Execute HANA Hardware Configuration Check Tool to bench filesystems"
  type        = bool
  default     = false
}

## Pre deployment

variable "pre_deployment" {
  description = "Enable pre deployment local execution. Only available for clients running Linux"
  type        = bool
  default     = false
}
