variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "hana_count" {
  type    = string
  default = "2"
}

variable "instance_type" {
  type    = string
  default = "r3.8xlarge"
}

variable "name" {
  description = "prefix of the machines names"
  type        = string
  default     = "hana"
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
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

variable "hana_inst_master" {
  type = string
}

variable "hana_inst_folder" {
  type    = string
  default = "/sapmedia/HANA"
}

variable "hana_platform_folder" {
  description = "Path to the hana platform media, relative to the 'hana_inst_master' mounting point"
  type        = string
  default     = ""
}

variable "hana_sapcar_exe" {
  description = "Path to the sapcar executable, relative to the 'hana_inst_master' mounting point"
  type        = string
  default     = ""
}

variable "hana_archive_file" {
  description = "Path to the HANA database server installation SAR archive or HANA platform archive file in zip or rar format, relative to the 'hana_inst_master' mounting point. Use this parameter if the hana media archive is not already extracted"
  type        = string
  default     = ""
}

variable "hana_extract_dir" {
  description = "Absolute path to folder where SAP HANA archive will be extracted"
  type        = string
  default     = "/sapmedia/HANA"
}

variable "hana_fstype" {
  description = "Filesystem type to use for HANA"
  type        = string
  default     = "xfs"
}

variable "hana_cluster_vip" {
  description = "IP address used to configure the hana cluster floating IP. It must be in other subnet than the machines!"
  type        = string
  default     = "192.168.1.10"
}

variable "hana_cluster_vip_secondary" {
  description = "IP address used to configure the hana cluster floating IP for the secondary node in an Active/Active mode"
  type        = string
  default     = ""
}

variable "ha_enabled" {
  description = "Enable HA cluster in top of HANA system replication"
  type        = bool
  default     = true
}

variable "fencing_mechanism" {
  description = "Choose the fencing mechanism for the cluster. Options: sbd, native"
  type        = string
}

variable "sbd_storage_type" {
  description = "Choose the SBD storage type. Options: iscsi"
  type        = string
  default     = "iscsi"
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

variable "hwcct" {
  description = "Execute HANA Hardware Configuration Check Tool to bench filesystems"
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
