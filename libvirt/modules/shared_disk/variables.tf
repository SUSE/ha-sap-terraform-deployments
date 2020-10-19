variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "name" {
  description = "name of the disk"
  type        = string
}

variable "pool" {
  description = "libvirt storage pool name for VM disks"
  default     = "default"
}

variable "shared_disk_size" {
  description = "shared partition disk size"
  default     = "104857600"               # 100MB
}

variable "shared_disk_count" {
  description = "variable used to decide to create or not the shared disk device"
  default     = 1
}
