variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type        = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = "string"
}

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
  type        = "map"
  default     = {}
}

variable "additional_repos" {
  description = "extra repositories used for installation {label = url}"
  default     = {}
}

variable "ha_sap_deployment_repo" {
  description = "Repository url used to install install HA/SAP deployment packages"
  type        = "string"
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  default     = []
}

variable "count" {
  description = "number of hosts like this one"
  default     = 1
}

variable "public_key_location" {
  description = "path of additional pub ssh key you want to use to access VMs"
  default     = "/dev/null"

  # HACK: "" cannot be used as a default because of https://github.com/hashicorp/hil/issues/50
}

variable "hana_disk_size" {
  description = "hana partition disk size"
  default     = "68719476736"              # 64GB
}

variable "hana_fstype" {
  description = "Filesystem type to use for HANA"
  type        = "string"
  default     = "xfs"
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = "list"
}

variable "shared_storage_type" {
  description = "used shared storage type for fencing (sbd). Available options: iscsi, shared-disk."
  type        = "string"
  default     = "iscsi"
}

variable "sbd_disk_id" {
  description = "SBD disk volume id"
  type        = "string"
}

variable "iscsi_srv_ip" {
  description = "iscsi server address"
  type        = "string"
  default     = ""
}

variable "sap_inst_media" {
  description = "URL of the NFS share where the SAP software installer is stored. This media shall be mounted in /root/sap_inst"
  type        = "string"
}

variable "hana_inst_folder" {
  description = "Folder where SAP HANA installation files are stored"
  type        = "string"
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

variable "memory" {
  description = "RAM memory in MiB"
  default     = 512
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default     = 1
}

variable "running" {
  description = "Whether this host should be turned on or off"
  default     = true
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default     = ""
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  default     = true
}
