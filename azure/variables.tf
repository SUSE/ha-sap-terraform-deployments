# Azure related variables

variable "az_region" {
  type    = string
  default = "westeurope"
}

variable "admin_user" {
  description = "administration user to deploy in Azure VMs"
  type        = string
}

variable "storage_account_name" {
  description = "Azure storage account name"
  type        = string
}

variable "storage_account_key" {
  description = "Azure storage account secret key"
  type        = string
}

variable "public_key_location" {
  description = "SSH Public key location to configure access to the remote instances"
  type        = string
}

variable "private_key_location" {
  description = "SSH Private key location"
  type        = string
}

# Deployment variables

variable "name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "hana"
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

variable "init_type" {
  type    = string
  default = "all"
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
  description = "extra packages which should be installed"
  default     = []
}

# Repository url used to install HA/SAP deployment packages"
# The latest RPM packages can be found at:
# https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/{YOUR OS VERSION}
# Contains the salt formulas rpm packages.
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages. If SLE version is not set, the deployment will automatically detect the current OS version"
  type        = string
}

variable "devel_mode" {
  description = "whether or not to install HA/SAP packages from ha_sap_deployment_repo"
  type        = bool
  default     = false
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
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

# Hana related variables

variable "hana_count" {
  type    = string
  default = "2"
}

variable "hana_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "hana_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "hana_public_sku" {
  type    = string
  default = "12-sp4"
}

variable "hana_public_version" {
  type    = string
  default = "latest"
}

variable "sles4sap_uri" {
  type    = string
  default = ""
}

# For reference:
# Standard_M32ls has 32 VCPU, 256GiB RAM, 1000 GiB SSD
# You could find other supported instances in Azure documentation
variable "hana_vm_size" {
  description = "VM size for the hana machine"
  type        = string
  default     = "Standard_M32ls"
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
  default = "ReadWrite"
}

variable "hana_enable_accelerated_networking" {
  description = "Enable accelerated networking. This function is mandatory for certified HANA environments and are not available for all kinds of instances. Check https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli for more details"
  type        = bool
  default     = true
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "hana_inst_master" {
  type = string
}

variable "hana_inst_folder" {
  type    = string
  default = "/sapmedia/HANA"
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

variable "hana_instance_number" {
  description = "HANA instance number"
  type        = string
  default     = "00"
}

# Iscsi server related variables

variable "iscsi_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "iscsi_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "iscsi_public_sku" {
  type    = string
  default = "15"
}

variable "iscsi_public_version" {
  type    = string
  default = "latest"
}

variable "iscsi_srv_uri" {
  type    = string
  default = ""
}

variable "iscsi_vm_size" {
  description = "VM size for the iscsi server machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "iscsi_srv_ip" {
  description = "iscsi server address"
  type        = string
  default     = "10.74.1.10"
}

variable "iscsidev" {
  description = "device iscsi for iscsi server"
  type        = string
}

variable "iscsi_disks" {
  description = "number of partitions attach to iscsi server. 0 means `all`."
  default     = 0
}

# Monitoring related variables

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

variable "monitoring_vm_size" {
  description = "VM size for the monitoring machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "monitoring_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "monitoring_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "monitoring_public_sku" {
  type    = string
  default = "15"
}

variable "monitoring_public_version" {
  type    = string
  default = "latest"
}

variable "monitoring_uri" {
  type    = string
  default = ""
}

variable "monitoring_srv_ip" {
  description = "monitoring server address"
  type        = string
  default     = ""
}

# DRBD related variables

variable "drbd_enabled" {
  description = "enable the DRBD cluster for nfs"
  type        = bool
  default     = false
}

variable "drbd_vm_size" {
  description = "VM size for the DRBD machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "drbd_ips" {
  description = "ip addresses to set to the drbd cluster nodes"
  type        = list(string)
  default     = []
}

variable "drbd_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "drbd_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "drbd_public_sku" {
  type    = string
  default = "15"
}

variable "drbd_public_version" {
  type    = string
  default = "latest"
}

variable "drbd_image_uri" {
  type    = string
  default = ""
}

# Netweaver related variables

variable "netweaver_enabled" {
  description = "enable SAP Netweaver cluster deployment"
  type        = bool
  default     = false
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

variable "netweaver_image_uri" {
  type    = string
  default = ""
}

variable "netweaver_vm_size" {
  description = "VM size for the Netweaver machines"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "netweaver_data_disk_type" {
  type    = string
  default = "Standard_LRS"
}

variable "netweaver_data_disk_size" {
  description = "Size of the Netweaver data disks, informed in GB"
  type        = string
  default     = "60"
}

variable "netweaver_data_disk_caching" {
  type    = string
  default = "ReadWrite"
}

variable "netweaver_ips" {
  description = "ip addresses to set to the netweaver cluster nodes"
  type        = list(string)
  default     = []
}

variable "netweaver_virtual_ips" {
  description = "virtual ip addresses to set to the netweaver cluster nodes"
  type        = list(string)
  default     = []
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

variable "netweaver_enable_accelerated_networking" {
  description = "Enable accelerated networking for netweaver. This function is mandatory for certified Netweaver environments and are not available for all kinds of instances. Check https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli for more details"
  type        = bool
  default     = true
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

# Specific QA variables

variable "qa_mode" {
  description = "define qa mode (Disable extra packages outside images)"
  type        = bool
  default     = false
}

variable "hwcct" {
  description = "Execute HANA Hardware Configuration Check Tool to bench filesystems"
  type        = bool
  default     = false
}

# Pre deployment

variable "pre_deployment" {
  description = "Enable pre deployment local execution"
  type        = bool
  default     = false
}
