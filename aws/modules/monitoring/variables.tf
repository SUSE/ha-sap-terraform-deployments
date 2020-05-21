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

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
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

variable "os_image" {
  description = "sles4sap AMI image identifier or a pattern used to find the image name (e.g. suse-sles-sap-15-sp1-byos)"
  type        = string
}

variable "os_owner" {
  description = "OS image owner"
  type        = string
}
