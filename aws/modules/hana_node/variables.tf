variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "network_domain" {
  description = "hostname's network domain"
  type        = string
}

variable "hana_count" {
  type    = string
  default = "2"
}

variable "instance_type" {
  type    = string
  default = "r3.8xlarge"
}

variable "aws_region" {
  type = string
}

variable "availability_zones" {
  type        = list(string)
  description = "Used availability zones"
}

variable "vpc_id" {
  type        = string
  description = "Id of the vpc used for this deployment"
}

variable "subnet_address_range" {
  type        = list(string)
  description = "List with subnet address ranges in cidr notation to create the netweaver subnets"
}

variable "key_name" {
  type        = string
  description = "AWS key pair name"
}

variable "security_group_id" {
  type        = string
  description = "Security group id"
}

variable "route_table_id" {
  type        = string
  description = "Route table id"
}

variable "aws_credentials" {
  description = "AWS credentials file path in local machine"
  type        = string
  default     = "~/.aws/credentials"
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "host_ips" {
  description = "ip addresses to set to the nodes. The first ip must be in 10.0.0.0/24 subnet and the second in 10.0.1.0/24 subnet"
  type        = list(string)
}

variable "hana_data_disk_type" {
  type    = string
  default = "gp2"
}

variable "hana_data_disk_size" {
  description = "Disk size in GB for the disk used to store HANA database content"
  type        = number
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

variable "reg_code" {
  description = "If informed, register the product using SUSEConnect"
  default     = ""
}

variable "on_destroy_dependencies" {
  description = "Resources objects need in the on_destroy script (everything that allows ssh connection)"
  type        = any
  default     = []
}

variable "os_image" {
  description = "sles4sap AMI image identifier or a pattern used to find the image name (e.g. suse-sles-sap-15-sp1-byos)"
  type        = string
}

variable "os_owner" {
  description = "OS image owner"
  type        = string
}
