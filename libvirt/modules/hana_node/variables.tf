variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

// repo and pkgs
variable "reg_code" {
  description = "If informed, register the product using SUSEConnect"
  default     = ""
}

variable "reg_email" {
  description = "Email used for the registration"
  default     = ""
}

variable "reg_additional_modules" {
  description = "Map of the modules to be registered. Module name = Regcode, when needed."
  type        = map(string)
  default     = {}
}

// hana
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages"
  type        = string
}

variable "devel_mode" {
  description = "Whether or not to install the HA/SAP packages from the `ha_sap_deployment_repo`"
  type        = bool
  default     = false
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  default     = []
}


variable "network_domain" {
  description = "hostname's network domain"
  default     = "tf.local"
}

variable "hana_count" {
  description = "number of hosts like this one"
  default     = 2
}

variable "public_key_location" {
  description = "path of pub ssh key you want to use to access VMs"
  default     = "~/.ssh/id_rsa.pub"
}

variable "hana_disk_size" {
  description = "hana partition disk size"
  default     = "68719476736" # 64GB
}

variable "hana_fstype" {
  description = "Filesystem type to use for HANA"
  type        = string
  default     = "xfs"
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "hana_cluster_vip" {
  description = "IP address used to configure the hana cluster floating IP. It must be in other subnet than the machines!"
  type        = string
}

variable "shared_storage_type" {
  description = "used shared storage type for fencing (sbd). Available options: iscsi, shared-disk."
  type        = string
  default     = "iscsi"
}

variable "sbd_disk_id" {
  description = "SBD disk volume id"
  type        = string
}

variable "iscsi_srv_ip" {
  description = "iscsi server address"
  type        = string
  default     = ""
}

variable "hana_inst_media" {
  description = "URL of the NFS share where the SAP HANA software installer is stored. This media shall be mounted in `hana_inst_folder`"
  type        = string
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

variable "hdbserver_sar" {
  description = "Path to the HANA database server installation sar archive, relative to the 'hana_inst_media' mounting point"
  type        = string
  default     = ""
}

variable "hana_extract_dir" {
  description = "Absolute path to folder where SAP HANA sar archive will be extracted"
  type        = string
  default     = "/sapmedia/HANA"
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

// Provider-specific variables

variable "source_image" {
  description = "Source image used to boot the machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "volume_name" {
  description = "Already existing volume name used to boot the machines. It must be in the same storage pool. It's only used if source_image is not provided"
  type        = string
  default     = ""
}

variable "memory" {
  description = "RAM memory in MiB"
  default     = 512
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default     = 1
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default     = ""
}

variable "isolated_network_id" {
  description = "Network id, internally created by terraform"
  type        = string
}

variable "isolated_network_name" {
  description = "Network name to attach the isolated network interface"
  type        = string
}

variable "storage_pool" {
  description = "libvirt storage pool name for VM disks"
  default     = "default"
}

variable "network_name" {
  description = "libvirt NAT network name for VMs, use empty string for bridged networking"
  default     = ""
}

variable "bridge" {
  description = "a bridge device name available on the libvirt host, leave default for NAT"
  default     = ""
}

// monitoring

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

// QA mode variables

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
