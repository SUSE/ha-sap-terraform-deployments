variable "machine_type" {
  type    = string
  default = "n1-standard-4"
}

variable "compute_zones" {
  description = "gcp compute zones data"
  type        = list(string)
}

variable "network_name" {
  description = "Network to attach the static route (temporary solution)"
  type        = string
}

variable "network_subnet_name" {
  description = "Subnet name to attach the network interface of the nodes"
  type        = string
}

variable "drbd_count" {
  description = "Cound of drbd cluster nodes"
  type        = string
  default     = "2"
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

variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP. It must be in other subnet than the machines!"
  type        = string
}

variable "gcp_credentials_file" {
  description = "Path to your local gcp credentials file"
  type        = string
}

variable "network_domain" {
  description = "hostname's network domain"
  default     = "tf.local"
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "iscsi_srv_ip" {
  description = "IP for iSCSI server"
  type        = string
}

variable "public_key_location" {
  type = string
}

variable "private_key_location" {
  type = string
}

variable "cluster_ssh_pub" {
  description = "path for the public key needed by the cluster"
  type        = string
}

variable "cluster_ssh_key" {
  description = "path for the private key needed by the cluster"
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

variable "reg_additional_modules" {
  description = "Map of the modules to be registered. Module name = Regcode, when needed."
  type        = map(string)
  default     = {}
}

# Generic variables

variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages"
  type        = string
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

variable "devel_mode" {
  description = "Whether or not to install the HA/SAP packages from the `ha_sap_deployment_repo`"
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

variable "on_destroy_dependencies" {
  description = "Resources objects need in the on_destroy script (everything that allows ssh connection)"
  type        = any
  default     = []
}
