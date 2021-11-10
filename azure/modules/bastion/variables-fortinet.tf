variable "fortinet_enabled" {
  type = bool
}

variable "fortinet_bastion_public_ip" {
  description = "Bastion public IP from fortinet module"
  type        = string
}

variable "fortinet_bastion_public_ip_id" {
  description = "Bastion public IP ID from fortinet module"
  type        = string
}
