variable "common_variables" {
  description = "Output of the common_variables module"
}

## IBM Cloud related variables
# https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-provider-reference#required-parameters

variable "ibmcloud_api_key" {
  description = "The IBM Cloud API key to authenticate with the IBM Cloud platform."
  default     = ""
}

variable "region" {
  description = "The IBM Cloud API key to authenticate with the IBM Cloud platform."
  default     = "eu-de"
}

variable "zone" {
  description = "The IBM Cloud API key to authenticate with the IBM Cloud platform."
  default     = "eu-de-1"
}

## IBM PowerVS related variables
# https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-power-vsi&locale=en

variable "pi_cloud_instance_id" {
  description = "The GUID of the service instance associated with an account."
  type        = string
}

variable "name" {
  description = "name of the disk"
  type        = string
}

variable "shared_type" {
  description = "Either tier1 or tier3"
  type    = string
  default = "tier1"
}

variable "shared_disk_size" {
  description = "shared disk size in GB"
  default     = "1"
}

variable "shared_disk_count" {
  description = "variable used to decide to create or not the shared disk device"
  default     = 1
}
