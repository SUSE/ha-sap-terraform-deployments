variable "fortinet_enabled" {
  description = "Create FortiGate AP ELB/ILB and FortiADC HA deployments"
  type        = bool
  default     = false
}

variable "fortinet_vm_publisher" {
  type    = string
  default = "fortinet"
}

variable "fortinet_vm_license_type" {
  description = "License type to use for fortinet VMs. 'Bring your own License' or 'Pay as you go'"
  type        = string
  default     = "byol"
  validation {
    condition = (
      can(regex("^(byol|payg)$", var.fortinet_vm_license_type))
    )
    error_message = "Invalid license type. Options: byol|payg ."
  }
}

variable "fortigate_a_license_file" {
  description = "Path to look for license file of Fortigate A VM."
  type        = string
  default     = "license_fortigate_a.lic"
}

variable "fortigate_b_license_file" {
  description = "Path to look for license file of Fortigate B VM."
  type        = string
  default     = "license_fortigate_b.lic"
}

variable "fortigate_os_image" {
  type    = string
  default = "fortinet:fortinet_fortigate-vm_v5:fortinet_fg-vm:7.0.2"
}

variable "fortigate_vm_size" {
  description = "VM Sizing for Fortigate VMs"
  type        = string
  default     = "Standard_F4s"
}

variable "fortigate_vm_username" {
  description = "Username for default Fortigate Admin user"
  type        = string
  default     = "azureuser"
}

variable "fortigate_vm_password" {
  description = "Password for default Fortigate Admin user"
  type        = string
  default     = ""
}

variable "fortiadc_a_license_file" {
  description = "Path to look for license file of FortiADC A VM."
  type        = string
  default     = "license_fortiadc_a.lic"
}

variable "fortiadc_b_license_file" {
  description = "Path to look for license file of FortiADC B VM."
  type        = string
  default     = "license_fortiadc_b.lic"
}

variable "fortiadc_os_image" {
  type    = string
  default = "fortinet:fortinet-fortiadc:fad-vm-byol:6.1.3"
}

variable "fortiadc_vm_size" {
  description = "VM Sizing for FortiADC VMs"
  type        = string
  default     = "Standard_F4s"
}

variable "fortiadc_vm_username" {
  description = "Username for default FortiADC Admin user"
  type        = string
  default     = "azureuser"
}

variable "fortiadc_vm_password" {
  description = "Password for default FortiADC Admin user"
  type        = string
  default     = ""
}

variable "fortinet_bastion_private_ip" {
  description = "Possibility to overwrite default bastion private IP"
  type        = string
  default     = ""
}
