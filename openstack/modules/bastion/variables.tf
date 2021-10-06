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

variable "bastion_flavor" {
  type    = string
  default = "2C-2GB-40GB"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "bastion_data_disk_name" {
  description = "Use existing volume to mount on bastion for NFS server"
  type        = string
}

variable "bastion_data_disk_type" {
  description = "Disk type of the disks used to serve as NFS server"
  type        = string
}

variable "bastion_data_disk_size" {
  description = "Disk Size of the disks used to serve as NFS server"
  type        = string
}

variable "network_domain" {
  description = "hostname's network domain"
  type        = string
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

variable "external_network_id" {
  description = "Already existing external network id in openstack"
  type        = string
  default     = ""
}

variable "floatingip_pool" {
  description = "Already existing floating IP pool in openstack"
  type        = string
  default     = ""
}

variable "router_interface_1" {
  description = "Router Interface to external network in openstack"
  type        = string
  default     = ""
}

variable "firewall_external" {
  description = "External firewall to attach VM to"
  type        = string
}

variable "firewall_internal" {
  description = "Internal firewall to attach VM to"
  type        = string
}

variable "bastion_count" {
  type    = string
  default = "0"
}

variable "bastion_srv_ip" {
  description = "bastion server address"
  type        = string
}

variable "on_destroy_dependencies" {
  description = "Resources objects need in the on_destroy script (everything that allows ssh connection)"
  type        = any
  default     = []
}
