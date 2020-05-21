variable "name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "drbd"
}

variable "drbd_count" {
  description = "Number of drbd machines to create the cluster"
  type        = number
  default     = 2
}

variable "drbd_instancetype" {
  description = "The instance type of drbd node"
  type        = string
  default     = "t2.micro"
}

variable "min_instancetype" {
  description = "The minimum cost/capacity instance type, different per region"
  type        = string
  default     = "t2.micro"
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
  description = "ip addresses to set to the nodes"
  type        = list(string)
}

variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP. It must be in other subnet than the machines!"
  type        = string
}

variable "drbd_data_disk_size" {
  description = "Disk size of the disks used to store drbd content"
  type        = string
  default     = "10"
}

variable "drbd_data_disk_type" {
  description = "Disk type of the disks used to store drbd content"
  type        = string
  default     = "gp2"
}

variable "network_domain" {
  type    = string
  default = "tf.local"
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

variable "iscsi_srv_ip" {
  description = "iscsi server address"
  type        = string
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
  type        = map(string)
  default     = {}
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  default     = []
}

variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages"
  type        = string
}

variable "devel_mode" {
  description = "Whether or not to install the HA/SAP packages from the `ha_sap_deployment_repo`"
  type        = bool
  default     = false
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
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

variable "qa_mode" {
  description = "Whether or not to install the HA/SAP packages from the `ha_sap_deployment_repo`"
  type        = bool
  default     = false
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
