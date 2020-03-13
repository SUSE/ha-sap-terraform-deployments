# Global variables

variable "project" {
  type = string
}

variable "gcp_credentials_file" {
  type = string
}

variable "public_key_location" {
  type = string
}

variable "private_key_location" {
  type = string
}

variable "machine_type" {
  type    = string
  default = "n1-highmem-32"
}

variable "iscsi_server_boot_image" {
  type    = string
  default = "suse-byos-cloud/sles-15-sap-byos"
}

variable "machine_type_iscsi_server" {
  type    = string
  default = "custom-1-2048"
}

variable "region" {
  type = string
}

variable "sles4sap_boot_image" {
  type    = string
  default = "suse-byos-cloud/sles-15-sap-byos"
}

variable "storage_url" {
  type    = string
  default = "https://storage.googleapis.com"
}

variable "ninstances" {
  type    = string
  default = "2"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "hana"
}

variable "init_type" {
  type    = string
  default = "all"
}

variable "iscsidev" {
  description = "device iscsi for iscsi server"
  type        = string
  default     = "/dev/sdb"
}

variable "iscsi_disks" {
  description = "number of partitions attach to iscsi server. 0 means `all`."
  default     = 0
}

variable "cluster_ssh_pub" {
  description = "path for the public key needed by the cluster"
  type        = string
}

variable "cluster_ssh_key" {
  description = "path for the private key needed by the cluster"
  type        = string
}

# HANA variables

variable "sap_hana_deployment_bucket" {
  description = "GCP storage bucket that contains the SAP HANA installation files"
  type        = string
}

variable "hana_inst_folder" {
  type    = string
  default = "/root/hana_inst_media"
}

variable "hana_data_disk_type" {
  type    = string
  default = "pd-ssd"
}

variable "hana_data_disk_size" {
  type    = string
  default = "834"
}

variable "hana_backup_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "hana_backup_disk_size" {
  type    = string
  default = "416"
}

variable "hana_disk_device" {
  description = "device where to install HANA"
  type        = string
  default     = "/dev/sdb"
}

variable "hana_backup_device" {
  description = "device where HANA backup is stored"
  type        = string
  default     = "/dev/sdc"
}

variable "hana_inst_disk_device" {
  description = "device where to download HANA"
  type        = string
  default     = "/dev/sdd"
}

variable "hana_fstype" {
  description = "Filesystem type to use for HANA"
  type        = string
  default     = "xfs"
}

variable "hana_cluster_vip" {
  description = "IP address used to configure the hana cluster floating IP. It must be in other subnet than the machines!"
  type        = string
}

# SUSE subscription variables

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
  description = "Repository url used to install HA/SAP deployment packages"
  type        = string
}

# Network variables
# Pay attention to set ip address according to the cidr range

variable "ip_cidr_range" {
  description = "internal IPv4 range"
}

variable "iscsi_ip" {
  description = "IP for iSCSI server"
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
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
  default     = false
}

# Specific QA variables

variable "qa_mode" {
  description = "define qa mode (Disable extra packages outside images)"
  default     = false
}

variable "hwcct" {
  description = "Execute HANA Hardware Configuration Check Tool to bench filesystems"
  type        = bool
  default     = false
}

# drbd related variables

variable "drbd_enabled" {
  description = "enable the DRBD cluster for nfs"
  default     = false
}

variable "drbd_machine_type" {
  description = "machine type for drbd nodes"
  type        = string
  default     = "n1-standard-4"
}

variable "drbd_image" {
  description = "image of the drbd nodes"
  type        = string
  default     = "suse-byos-cloud/sles-15-sap-byos"
}

variable "drbd_data_disk_size" {
  description = "drbd data disk size"
  type        = string
  default     = "10"
}

variable "drbd_data_disk_type" {
  description = "drbd data disk type"
  type        = string
  default     = "pd-standard"
}

variable "drbd_ips" {
  description = "ip addresses to set to the drbd cluster nodes"
  type        = list(string)
  default     = []
}

variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP. It must be in other subnet than the machines!"
  type        = string
}

# netweaver realted variables

variable "netweaver_enabled" {
  description = "enable netweaver cluster creation"
  default     = false
}

variable "netweaver_machine_type" {
  description = "machine type for netweaver nodes"
  type        = string
  default     = "n1-highmem-8"
}

variable "netweaver_image" {
  description = "image of the netweaver nodes"
  type        = string
  default     = "suse-byos-cloud/sles-15-sap-byos"
}

variable "netweaver_software_bucket" {
  description = "gcp bucket where netweaver software is available"
  type        = string
  default     = ""
}

variable "netweaver_ips" {
  description = "ip addresses to set to the netweaver cluster nodes"
  type        = list(string)
  default     = []
}

variable "netweaver_virtual_ips" {
  description = "virtual ip addresses to set to the nodes. The first 2 nodes will be part of the HA cluster so they addresses must be outside of the subnet mask"
  type        = list(string)
}
