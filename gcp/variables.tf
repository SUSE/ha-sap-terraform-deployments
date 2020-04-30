# GCP related variables

variable "project" {
  description = "GCP project name where the infrastructure will be created"
  type        = string
}

variable "region" {
  description = "GCP region where the deployment machines will be created"
  type        = string
}

variable "gcp_credentials_file" {
  description = "GCP credentials file path in local machine"
  type        = string
}

variable "vpc_name" {
  description = "Already existing vpc name used by the created infrastructure. If it's not set a new one will be created"
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created"
  type        = string
  default     = ""
}

variable "create_firewall_rules" {
  description = "Create predifined firewall rules for the connections outside the network (internal connections are always allowed). Set to false if custom firewall rules are already created for the used network"
  type        = bool
  default     = true
}

variable "ip_cidr_range" {
  description = "Internal IPv4 range of the created network"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_key_location" {
  description = "Path to a SSH public key used to connect to the created machines"
  type        = string
}

variable "private_key_location" {
  description = "Path to a SSH private key used to connect to the created machines"
  type        = string
}

# Deployment variables

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
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

# Repository url used to install HA/SAP deployment packages"
# The latest RPM packages can be found at:
# https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/{YOUR OS VERSION}
# Contains the salt formulas rpm packages.
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages. If SLE version is not set, the deployment will automatically detect the current OS version"
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

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "devel_mode" {
  description = "Increase ha_sap_deployment_repo repository priority to get the packages from this repository instead of SLE official channels"
  type        = bool
  default     = false
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  type        = bool
  default     = false
}

# Hana related variables

variable "hana_count" {
  description = "Number of hana nodes"
  type        = string
  default     = "2"
}

variable "machine_type" {
  description = "The instance type of the hana nodes"
  type        = string
  default     = "n1-highmem-32"
}

variable "init_type" {
  description = "Type of deployment. Options: all-> Install HANA and HA; skip-hana-> Skip HANA installation; skip-cluster-> Skip HA cluster installation"
  type        = string
  default     = "all"
}

variable "sles4sap_boot_image" {
  description = "The image used to create the hana machines"
  type        = string
  default     = "suse-byos-cloud/sles-15-sap-byos"
}

variable "hana_ips" {
  description = "ip addresses to set to the hana nodes. They must be in the same network addresses range defined in `ip_cidr_range`"
  type        = list(string)
  default     = []
}

variable "sap_hana_deployment_bucket" {
  description = "GCP storage bucket that contains the SAP HANA installation files"
  type        = string
}

variable "hana_inst_folder" {
  description = "Folder where the hana installation software will be downloaded"
  type        = string
  default     = "/sapmedia/HANA"
}

variable "hana_platform_folder" {
  description = "Path to the hana platform media, relative to the hana_inst_folder"
  type        = string
  default     = ""
}

variable "hana_sapcar_exe" {
  description = "Path to the sapcar executable, relative to the hana_inst_folder"
  type        = string
  default     = ""
}

variable "hdbserver_sar" {
  description = "Path to the HANA database server installation sar archive, relative to the hana_inst_folder"
  type        = string
  default     = ""
}

variable "hana_extract_dir" {
  description = "Absolute path to folder where SAP HANA sar archive will be extracted"
  type        = string
  default     = "/sapmedia/HANA"
}

variable "hana_data_disk_type" {
  description = "Disk type of the disks used to store hana database content"
  type        = string
  default     = "pd-ssd"
}

variable "hana_data_disk_size" {
  description = "Disk size of the disks used to store hana database content"
  type        = string
  default     = "834"
}

variable "hana_backup_disk_type" {
  description = "Disk type of the disks used to store hana database backup content"
  type        = string
  default     = "pd-standard"
}

variable "hana_backup_disk_size" {
  description = "Disk size of the disks used to store hana database backup content"
  type        = string
  default     = "416"
}

variable "hana_fstype" {
  description = "Filesystem type used by the disk where hana is installed"
  type        = string
  default     = "xfs"
}

variable "hana_cluster_vip" {
  description = "IP address used to configure the hana cluster floating IP. It must be in other subnet than the machines!"
  type        = string
  default     = ""
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
}

# Monitoring related variables
variable "monitoring_srv_ip" {
  description = "Monitoring server address"
  type        = string
  default     = ""
}
variable "monitoring_enabled" {
  description = "Enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

# Iscsi server related variables

variable "iscsi_server_boot_image" {
  description = "The image used to create the iscsi machines"
  type        = string
  default     = "suse-byos-cloud/sles-15-sap-byos"
}

variable "machine_type_iscsi_server" {
  description = "The instance type of the iscsi nodes"
  type        = string
  default     = "custom-1-2048"
}

variable "iscsi_srv_ip" {
  description = "IP for iSCSI server. It must be in the same network addresses range defined in `ip_cidr_range`"
  type        = string
  default     = ""
}

variable "iscsi_disks" {
  description = "Number of partitions attach to iscsi server. 0 means `all`."
  default     = 0
}

# DRBD related variables

variable "drbd_enabled" {
  description = "Enable the DRBD cluster for nfs"
  type        = bool
  default     = false
}

variable "drbd_machine_type" {
  description = "The instance type of the drbd nodes"
  type        = string
  default     = "n1-standard-4"
}

variable "drbd_image" {
  description = "The image used to create the drbd machines"
  type        = string
  default     = "suse-byos-cloud/sles-15-sap-byos"
}

variable "drbd_data_disk_size" {
  description = "Disk size of the disks used to store drbd content"
  type        = string
  default     = "10"
}

variable "drbd_data_disk_type" {
  description = "Disk type of the disks used to store drbd content"
  type        = string
  default     = "pd-standard"
}

variable "drbd_ips" {
  description = "ip addresses to set to the drbd cluster nodes. They must be in the same network addresses range defined in `ip_cidr_range`"
  type        = list(string)
  default     = []
}

variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP. It must be in other subnet than the machines!"
  type        = string
  default     = ""
}

# Netweaver related variables

variable "netweaver_enabled" {
  description = "Enable netweaver cluster creation"
  type        = bool
  default     = false
}

variable "netweaver_machine_type" {
  description = "The instance type of the netweaver nodes"
  type        = string
  default     = "n1-highmem-8"
}

variable "netweaver_image" {
  description = "The image used to create the netweaver machines"
  type        = string
  default     = "suse-byos-cloud/sles-15-sap-byos"
}

variable "netweaver_software_bucket" {
  description = "GCP storage bucket that contains the netweaver installation files"
  type        = string
  default     = ""
}

variable "netweaver_ips" {
  description = "ip addresses to set to the netweaver cluster nodes. They must be in the same network addresses range defined in `ip_cidr_range`"
  type        = list(string)
  default     = []
}

variable "netweaver_virtual_ips" {
  description = "virtual ip addresses to set to the nodes. The first 2 nodes will be part of the HA cluster so they addresses must be outside of the subnet mask"
  type        = list(string)
  default     = []
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
  description = "Enable test/qa mode (disable extra packages usage not coming in the image)"
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
  description = "Enable pre deployment local execution. Only available for clients running Linux"
  type        = bool
  default     = false
}
