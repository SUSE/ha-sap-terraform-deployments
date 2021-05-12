variable "name" {
  description = "Prefix name used to create the load balancer resources"
  type        = string
}

variable "region" {
  description = "Region where the load balancer is deployed"
  type        = string
}

variable "network_name" {
  description = "Network where the load balancer resources are attached"
  type        = string
}

variable "network_subnet_name" {
  description = "Subnetwork which has the load balancer attached"
  type        = string
}

variable "primary_node_group" {
  description = "Primary node group. The load balancer forwards to this group the traffic by default"
  type        = string
}

variable "secondary_node_group" {
  description = "Secondary node id. The load balancer forwards to this group the traffic as fallback option"
  type        = string
}

variable "tcp_health_check_port" {
  description = "Port used to check the health of the node"
  type        = number
}

variable "target_tags" {
  description = "List of tags applied to the virtual machines which are used by the load balancer firewall rule"
  type        = list(string)
}

variable "ip_address" {
  description = "IP address which the data is forwarded"
  type        = string
}
