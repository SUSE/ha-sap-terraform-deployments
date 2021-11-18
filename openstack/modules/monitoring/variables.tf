variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "region" {
  description = "OpenStack Availability Zone region where the deployment machines will be created"
  type        = string
}

variable "region_net" {
  description = "OpenStack Availability Zone region where the networks will be created"
  type        = string
}

variable "flavor" {
  type    = string
  default = "4C-8GB-40GB"
}

variable "network_name" {
  description = "Network to attach the static route (temporary solution)"
  type        = string
}

variable "network_subnet_name" {
  description = "Subnet name to attach the network interface of the nodes"
  type        = string
}

variable "network_id" {
  description = "Network ID to attach the static route (temporary solution)"
  type        = string
}

variable "network_subnet_id" {
  description = "Subnet ID to attach the network interface of the nodes"
  type        = string
}

variable "os_image" {
  description = "Image used to create the machine"
  type        = string
}

variable "userdata" {
  description = "userdata to inject into compute instance"
  type        = string
}

variable "bastion_host" {
  description = "Bastion host address"
  type        = string
  default     = ""
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "firewall_internal" {
  description = "Internal firewall to attach VM to"
  type        = string
}

variable "network_domain" {
  type    = string
  default = "tf.local"
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

variable "monitoring_srv_ip" {
  description = "Monitoring server address"
  type        = string
  default     = ""
}

variable "hana_targets" {
  description = "IPs of HANA hosts you want to monitor; the last one is assumed to be the virtual IP of the active HA instance."
  type        = list(string)
}

variable "drbd_targets" {
  description = "IPs of DRBD hosts you want to monitor"
  type        = list(string)
  default     = []
}

variable "netweaver_targets" {
  description = "IPs of Netweaver hosts you want to monitor; the first two are assumed to be the virtual IPs of the HA instances."
  type        = list(string)
  default     = []
}

variable "on_destroy_dependencies" {
  description = "Resources objects need in the on_destroy script (everything that allows ssh connection)"
  type        = any
  default     = []
}
