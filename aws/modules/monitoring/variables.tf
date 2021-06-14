variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "monitoring_enabled" {
  description = "enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "The instance type of monitoring node."
  type        = string
  default     = "t3.micro"
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

variable "hana_targets" {
  description = "IPs of HANA hosts you want to monitor."
  type        = list(string)
}

variable "hana_targets_ha" {
  description = "IPs of HANA HA hosts you want to monitor."
  type        = list(string)
}

variable "hana_targets_vip" {
  description = "VIPs of HANA DBs you want to monitor."
  type        = list(string)
}

variable "drbd_targets" {
  description = "IPs of DRBD hosts you want to monitor"
  type        = list(string)
  default     = []
}

variable "drbd_targets_ha" {
  description = "IPs of DRBD HA hosts you want to monitor"
  type        = list(string)
  default     = []
}

variable "drbd_targets_vip" {
  description = "VIPs of DRBD NFS services you want to monitor"
  type        = list(string)
  default     = []
}

variable "netweaver_targets" {
  description = "IPs of Netweaver hosts you want to monitor."
  type        = list(string)
  default     = []
}

variable "netweaver_targets_ha" {
  description = "IPs of Netweaver HA hosts you want to monitor."
  type        = list(string)
  default     = []
}

variable "netweaver_targets_vip" {
  description = "VIPs of Netweaver Instances you want to monitor."
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
