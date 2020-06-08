# AWS related variables

variable "aws_region" {
  description = "AWS region where the deployment machines will be created. If not provided the current configured region will be used"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS access key id"
  type        = string
  default     = ""
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
  default     = ""
}

variable "aws_credentials" {
  description = "AWS credentials file path in local machine. This file will be used it `aws_access_key_id` and `aws_secret_access_key` are not provided"
  type        = string
  default     = "~/.aws/credentials"
}

variable "vpc_id" {
  description = "Id of a currently existing vpc to use in the deployment. It must have an internet gateway attached. If not provided a new one will be created."
  type        = string
  default     = ""
}

variable "security_group_id" {
  description = "Id of a currently existing security group to use in the deployment. If not provided a new one will be created"
  type        = string
  default     = ""
}

variable "vpc_address_range" {
  description = "vpc address range in CIDR notation"
  type        = string
  default     = "10.0.0.0/16"
}

variable "virtual_address_range" {
  description = "address range for virtual addresses for the clusters. It must be in a different range than `vpc_address_range`"
  type        = string
  default     = "192.168.1.0/24"
}

variable "infra_subnet_address_range" {
  description = "Address range to create the subnet for the infrastructure (iscsi, monitoring, etc) machines. If not given the addresses will be generated based on vpc_address_range"
  type        = string
  default     = ""
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

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
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

# Repository url used to install HA/SAP deployment packages"
# The latest RPM packages can be found at:
# https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/{YOUR OS VERSION}
# Contains the salt formulas rpm packages.
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages. If SLE version is not set, the deployment will automatically detect the current OS version"
  type        = string
}

variable "devel_mode" {
  description = "Increase ha_sap_deployment_repo repository priority to get the packages from this repository instead of SLE official channels"
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

# Hana related variables

variable "hana_count" {
  description = "Number of hana nodes"
  type        = number
  default     = 2
}

variable "hana_os_image" {
  description = "sles4sap AMI image identifier or a pattern used to find the image name (e.g. suse-sles-sap-15-sp1-byos)"
  type        = string
  default     = "suse-sles-sap-15-sp1-byos"
}

variable "hana_os_owner" {
  description = "OS image owner"
  type        = string
  default     = "amazon"
}

variable "hana_instancetype" {
  description = "The instance type of the hana nodes"
  type        = string
  default     = "r3.8xlarge"
}

variable "hana_subnet_address_range" {
  description = "List of address ranges to create the subnets for the hana machines. If not given the addresses will be generated based on vpc_address_range"
  type        = list(string)
  default     = []
}

variable "hana_ips" {
  description = "ip addresses to set to the nodes. The first ip must be in 10.0.0.0/24 subnet and the second in 10.0.1.0/24 subnet"
  type        = list(string)
  default     = []
}

variable "hana_inst_master" {
  description = "S3 bucket folder path where hana installation software is available"
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
  description = "Path to the sapcar executable, relative to the 'hana_inst_master' mounting point"
  type        = string
  default     = ""
}

variable "hdbserver_sar" {
  description = "Path to the HANA database server installation sar archive, relative to the 'hana_inst_master' mounting point"
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
  default     = "gp2"
}

variable "hana_disk_device" {
  description = "Device where hana is installed"
  type        = string
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

variable "hana_cluster_sbd_enabled" {
  description = "Enable sbd usage in the hana HA cluster"
  type        = bool
  default     = false
}

variable "hana_ha_enabled" {
  description = "Enable HA cluster in top of HANA system replication"
  type        = bool
  default     = true
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
}

# DRBD related variables

variable "drbd_enabled" {
  description = "Enable the DRBD cluster for nfs"
  type        = bool
  default     = false
}

variable "drbd_os_image" {
  description = "sles4sap AMI image identifier or a pattern used to find the image name (e.g. suse-sles-sap-15-sp1-byos)"
  type        = string
  default     = "suse-sles-sap-15-sp1-byos"
}

variable "drbd_os_owner" {
  description = "OS image owner"
  type        = string
  default     = "amazon"
}

variable "drbd_instancetype" {
  description = "The instance type of the drbd node"
  type        = string
  default     = "t2.micro"
}

variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP"
  type        = string
  default     = ""
}

variable "drbd_ips" {
  description = "ip addresses to set to the drbd cluster nodes. If it's not set the addresses will be auto generated from the provided vnet address range"
  type        = list(string)
  default     = []
}

variable "drbd_subnet_address_range" {
  description = "List of address ranges to create the subnets for the drbd machines. If not given the addresses will be generated based on vpc_address_range"
  type        = list(string)
  default     = []
}

variable "drbd_data_disk_size" {
  description = "Disk size of the disks used to store drbd content"
  type        = string
  default     = "15"
}

variable "drbd_data_disk_type" {
  description = "Disk type of the disks used to store drbd content"
  type        = string
  default     = "gp2"
}

variable "drbd_cluster_sbd_enabled" {
  description = "Enable sbd usage in the drbd HA cluster"
  type        = bool
  default     = false
}

# SBD related variables
# In order to enable SBD, an ISCSI server is needed as right now is the unique option
# All the clusters will use the same mechanism

variable "sbd_storage_type" {
  description = "Choose the SBD storage type. Options: iscsi"
  type        = string
  default     = "iscsi"
}

# If iscsi is selected as sbd_storage_type
# Use the next variables for advanced configuration

variable "iscsi_os_image" {
  description = "sles4sap AMI image identifier or a pattern used to find the image name (e.g. suse-sles-sap-15-sp1-byos)"
  type        = string
  default     = "suse-sles-sap-15-sp1-byos"
}

variable "iscsi_os_owner" {
  description = "OS image owner"
  type        = string
  default     = "amazon"
}

variable "iscsi_instancetype" {
  description = "The instance type of the iscsi server node."
  type        = string
  default     = "t2.micro"
}

variable "iscsi_srv_ip" {
  description = "iscsi server address. It should be in same iprange as host_ips"
  type        = string
  default     = ""
}

variable "iscsi_lun_count" {
  description = "Number of LUN (logical units) to serve with the iscsi server. Each LUN can be used as a unique sbd disk"
  default     = 3
}

variable "iscsi_disk_size" {
  description = "Disk size in GB used to create the LUNs and partitions to be served by the ISCSI service"
  type        = number
  default     = 10
}

# Monitoring related variables

variable "monitoring_os_image" {
  description = "sles4sap AMI image identifier or a pattern used to find the image name (e.g. suse-sles-sap-15-sp1-byos)"
  type        = string
  default     = "suse-sles-sap-15-sp1-byos"
}

variable "monitoring_os_owner" {
  description = "OS image owner"
  type        = string
  default     = "amazon"
}

variable "monitor_instancetype" {
  description = "The instance type of the monitoring node."
  type        = string
  default     = "t2.micro"
}

variable "monitoring_srv_ip" {
  description = "monitoring server address. Must be in 10.0.0.0/24 subnet"
  type        = string
  default     = ""
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

# Netweaver related variables

variable "netweaver_enabled" {
  description = "Enable SAP Netweaver cluster deployment"
  type        = bool
  default     = false
}

variable "netweaver_os_image" {
  description = "sles4sap AMI image identifier or a pattern used to find the image name (e.g. suse-sles-sap-15-sp1-byos)"
  type        = string
  default     = "suse-sles-sap-15-sp1-byos"
}

variable "netweaver_os_owner" {
  description = "OS image owner"
  type        = string
  default     = "amazon"
}

variable "netweaver_instancetype" {
  description = "Instance type for the Netweaver machines. Default to r3.8xlarge"
  type        = string
  default     = "r3.8xlarge"
}

variable "netweaver_s3_bucket" {
  description = "S3 bucket where Netwaever installation files are stored"
  type        = string
  default     = ""
}

variable "netweaver_efs_performance_mode" {
  type        = string
  description = "Performance mode of the EFS storage used by Netweaver"
  default     = "generalPurpose"
}

variable "netweaver_subnet_address_range" {
  description = "List of address ranges to create the subnets for the netweaver machines. If not given the addresses will be generated based on vpc_address_range"
  type        = list(string)
  default     = []
}

variable "netweaver_ips" {
  description = "ip addresses to set to the netweaver cluster nodes"
  type        = list(string)
  default     = []
}

variable "netweaver_virtual_ips" {
  description = "Virtual ip addresses to set to the netweaver cluster nodes"
  type        = list(string)
  default     = []
}

variable "netweaver_cluster_sbd_enabled" {
  description = "Enable sbd usage in the netweaver HA cluster"
  type        = bool
  default     = false
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

variable "netweaver_ha_enabled" {
  description = "Enable HA cluster in top of Netweaver ASCS and ERS instances"
  type        = bool
  default     = true
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
