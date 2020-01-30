# Launch SLES-HAE of SLES4SAP cluster nodes

# Variables for type of instances to use and number of cluster nodes
# Use with: terraform apply -var instancetype=Small -var hana_count=2

variable "instancetype" {
  type    = string
  default = "Standard_M128s"
}

# For reference:
# Standard_B1ms has 1 VCPU, 2GiB RAM, 1 NIC, 2 data disks and 4GiB SSD
# Standard_D2s_v3 has 2 VCPU, 8GiB RAM, 2 NICs, 4 data disks and 16GiB SSD disk
# Standard_D8s_v3 has 8 VCPU, 32GiB RAM, 2 NICs, 16 data disks and 64GiB SSD disk
# Standard_E4s_v3 has 4 VCPU, 32GiB RAM, 2 NICs, 64GiB SSD disk
# Standard_M32ts has 32 VCPU, 192GiB RAM, 1000 GiB SSD

variable "hana_count" {
  type    = string
  default = "2"
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

variable "name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "hana"
}

variable "hana_instance_number" {
  description = "HANA instance number"
  type        = string
  default     = "00"
}

# Variable for default region where to deploy resources

variable "az_region" {
  type    = string
  default = "westeurope"
}

variable "init_type" {
  type    = string
  default = "all"
}

variable "hana_inst_master" {
  type = string
}

variable "hana_inst_folder" {
  type    = string
  default = "/root/hana_inst_media"
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

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "drbd_ips" {
  description = "ip addresses to set to the drbd cluster nodes"
  type        = list(string)
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

variable "drbd_enabled" {
  description = "enable the DRBD cluster for nfs"
  default     = false
}

# Netweaver variables

variable "netweaver_enabled" {
  description = "enable SAP Netweaver cluster deployment"
  default     = false
}

variable "netweaver_vm_size" {
  description = "VM size for the Netweaver machines. Default to Standard_D2s_v3"
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
