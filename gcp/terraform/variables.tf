# Deployment
variable "name" {
  default = "testing"
}

variable "gcp_credentials_file" {
  type = "string"
}

variable "suse_regcode" {}

variable "ssh_key_file" {}
variable "ssh_pub_key_file" {}

variable "ip_cidr_range" {}

variable "sap_vip" {}

variable "iscsi_ip" {}

variable "machine_type" {}
variable "machine_type_iscsi_server" {}

variable "region" {}
variable "project" {}

variable "sap_hana_sidadm_password" {
  description = "The password for the operating system administrator. Passwords must be at least eight characters and include at least one uppercase letter, one lowercase letter, and one number"
  type        = "string"
}

variable "sap_hana_system_password" {
  description = "The password for the database superuser. Passwords must be at least 8 characters and include at least one uppercase letter, one lowercase letter, and one number"
  type        = "string"
}

variable "sap_deployment_debug" {}
variable "sap_hana_instance_number" {}
variable "sap_hana_deployment_bucket" {}
variable "sap_hana_sidadm_uid" {}
variable "sap_hana_sapsys_gid" {}
variable "sap_hana_sid" {}

variable "images_path_bucket" {}
variable "sles4sap_os_image_file" {}
variable "sles_os_image_file" {}

variable "storage_url" {
  type    = "string"
  default = "https://storage.googleapis.com"
}

variable "post_deployment_script" {}

variable "init_type" {
  type    = "string"
  default = "all"
}

variable "use_gcp_stonith" {
  type = "string"
}
