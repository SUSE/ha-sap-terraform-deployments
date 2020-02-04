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

variable "cluster_ssh_pub" {
  description = "path for the public key needed by the cluster"
  type        = string
  default     = ""
}

variable "cluster_ssh_key" {
  description = "path for the private key needed by the cluster"
  type        = string
  default     = ""
}

// hana
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages"
  type        = string
}

variable "devel_mode" {
  description = "Whether or not to install the HA/SAP packages from the `ha_sap_deployment_repo`"
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

// Provider-specific variables

variable "base_image_id" {
  description = "base image id which the module will use. You can create a baseimage and module will use it. Created in main.tf"
  type        = string
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

variable "network_id" {
  description = "network id to be injected into domain. normally the isolated network is created in main.tf"
  type        = string
}

variable "network_name" {
  description = "libvirt NAT network name for VMs, use empty string for bridged networking"
  default     = ""
}

variable "bridge" {
  description = "a bridge device name available on the libvirt host, leave default for NAT"
  default     = ""
}

variable "pool" {
  description = "libvirt storage pool name for VM disks"
  default     = "default"
}

// monitoring

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  default     = false
}

// QA mode variables

variable "qa_mode" {
  description = "define qa mode (Disable extra packages outside images)"
  default     = false
}

variable "hwcct" {
  description = "Execute HANA Hardware Configuration Check Tool to bench filesystems"
  type        = bool
  default     = false
}
