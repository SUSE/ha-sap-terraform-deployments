variable "monitor_instancetype" {
  description = "The instance type of monitoring node."
  type        = string
  default     = ""
}

variable "min_instancetype" {
  description = "The minimum cost/capacity instance type, different per region."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  type        = string
  description = "AWS key pair name"
}

variable "security_group_id" {
  type        = string
  description = "Security group id"
}

variable "monitoring_srv_ip" {
  description = "monitoring server address"
  type        = string
  default     = ""
}

variable "private_key_location" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "availability_zones" {
  type        = list(string)
  description = "Used availability zones"
}

variable "sles4sap_images" {
  type = map(string)

  default = {
    "us-east-1"    = "ami-027447d2b7312df2d"
    "us-east-2"    = "ami-099a51d3b131f3ce2"
    "us-west-1"    = "ami-0f213357578720889"
    "us-west-2"    = "ami-0fc86417df3e0f6d4"
    "ca-central-1" = "ami-0811b93a30ab570f7"
    "eu-central-1" = "ami-024f50fdc1f2f5603"
    "eu-west-1"    = "ami-0ca96dfbaf35b0c31"
    "eu-west-2"    = "ami-00189dbab3fd43af2"
    "eu-west-3"    = "ami-00e70e3421f053648"
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "host_ips" {
  description = "ip addresses to set to the nodes. The first ip must be in 10.0.0.0/24 subnet and the second in 10.0.1.0/24 subnet"
  type        = list(string)
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
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

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  type        = bool
  default     = false
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

variable "netweaver_enabled" {
  description = "enable SAP Netweaver cluster deployment"
  default     = false
}

variable "netweaver_ips" {
  description = "ip addresses to set to the netweaver cluster nodes"
  type        = list(string)
  default     = []
}

variable "on_destroy_dependencies" {
  description = "Resources objects need in the on_destroy script (everything that allows ssh connection)"
  type        = any
  default     = []
}
