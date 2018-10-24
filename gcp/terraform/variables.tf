# Use with: terraform plan/apply -var "date_of_the_day=$(date +%Y%m%d)"

variable "gcp_credentials_file" {
  description = "Credentials file for GCP"
  type        = "string"
  default     = "suse-css-qa-4a2108492696.json"
}

variable "ssh_user" {
  description = "SSH user for connection"
  type        = "string"
  default     = "root"
}

variable "ssh_pub_key_file" {
  description = "SSH public key file"
  type        = "string"
  default     = "ssh_pub.key"
}

variable "date_of_the_day" {
  description = "Date of the current day"
  type        = "string"
}

variable "sle_version" {
  description = "SLE OS version"
  type        = "string"
  default = "12sp4"
}

variable "ip_cidr_range" {
  description = "Private Network"
  type        = "string"
  default     = "10.0.0.0/16"
}

variable "node_list" {
  description = "List of SAP/HA nodes"
  type        = "list"
  default     = ["node-1", "node-2"]
}

variable "node_count" {
  description = "Number of HA/SAP nodes"
  type        = "string"
  default     = "2"                      # ${length(var.node_list)}"
}

variable "machine_type_hana_node" {
  description = "Type of VM (vCPUs and RAM)"
  type        = "string"
  default     = "n1-highmem-32"
}

variable "machine_type_iscsi_server" {
  description = "Type of VM (vCPUs and RAM)"
  type        = "string"
  default     = "custom-1-2048"
}

variable "region" {
  description = "Resources' location"
  type        = "string"
  default     = "europe-west3"
}

variable "zone" {
  description = "Resources' zone"
  type        = "string"
  default     = "europe-west3-a"
}

variable "images_path" {
  description = "Path to SLE Cloud images"
  type        = "string"
  default     = "public_cloud_images"
}

variable "images_path_bucket" {
  description = "Path to SLE Cloud images in bucket"
  type        = "string"
  default     = "sle-image-store"
}

variable "sles_os_image_file" {
  description = "Name of SLES image file"
  type        = "string"
  default     = "SLES12-SP4-GCE-BYOS.x86_64-0.9.3-Build1.26.tar.gz"
}

variable "sles4sap_os_image_file" {
  description = "Name of SLES4SAP image file"
  type        = "string"
  default     = "SLES12-SP4-SAP-GCE-BYOS.x86_64-0.9.4-Build1.33.tar.gz"
}

variable "storage_url" {
  description = "GCP storage URL"
  type        = "string"
  default     = "https://storage.googleapis.com"
}
