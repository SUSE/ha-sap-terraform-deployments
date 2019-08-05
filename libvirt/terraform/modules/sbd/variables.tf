variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
  type        = map(string)
}

variable "sbd_disk_size" {
  description = "sbd partition disk size"
  default     = "104857600" # 100MB
}

variable "sbd_count" {
  description = "variable used to decide to create or not the sbd shared disk device"
  default     = 1
}
