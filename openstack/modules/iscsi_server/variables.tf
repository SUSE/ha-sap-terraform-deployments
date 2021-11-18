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
  default = "2C-2GB-40GB"
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
  description = "List of ip addresses to set to the machines"
  type        = list(string)
}

variable "firewall_internal" {
  description = "Internal firewall to attach VM to"
  type        = string
}

variable "network_domain" {
  description = "hostname's network domain"
  default     = "tf.local"
}

variable "iscsi_srv_ip" {
  description = "iscsi server address"
  type        = string
}

variable "iscsi_count" {
  type        = number
  description = "Number of iscsi machines to deploy"
}

variable "iscsi_disk_size" {
  description = "Disk size in GB used to create the LUNs and partitions to be served by the ISCSI service"
  type        = number
  default     = 10
}

variable "lun_count" {
  description = "Number of LUN (logical units) to serve with the iscsi server. Each LUN can be used as a unique sbd disk"
  type        = number
  default     = 3
}

variable "on_destroy_dependencies" {
  description = "Resources objects need in the on_destroy script (everything that allows ssh connection)"
  type        = any
  default     = []
}
