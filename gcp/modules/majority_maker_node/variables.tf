variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "bastion_host" {
  description = "Bastion host address"
  type        = string
  default     = ""
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "hana_count" {
  type = string
}

variable "node_count" {
  type = string
}

variable "machine_type" {
  type = string
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

variable "os_image" {
  description = "Image used to create the machine"
  type        = string
}

variable "network_domain" {
  description = "hostname's network domain"
  type        = string
}

variable "gcp_credentials_file" {
  description = "Path to your local gcp credentials file"
  type        = string
}

variable "host_ips" {
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "majority_maker_ip" {
  description = "ip address to set to the HANA Majority Maker node. If it's not set the addresses will be auto generated from the provided vnet address range"
  type        = string
  validation {
    condition = (
      var.majority_maker_ip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.majority_maker_ip))
    )
    error_message = "Invalid IP address format."
  }
}

variable "iscsi_srv_ip" {
  description = "iscsi server address"
  type        = string
}

variable "cluster_ssh_pub" {
  description = "path for the public key needed by the cluster"
  type        = string
}

variable "cluster_ssh_key" {
  description = "path for the private key needed by the cluster"
  type        = string
}

variable "on_destroy_dependencies" {
  description = "Resources objects need in the on_destroy script (everything that allows ssh connection)"
  type        = any
  default     = []
}
