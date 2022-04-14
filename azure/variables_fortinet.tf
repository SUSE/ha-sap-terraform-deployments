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
  description = "License type to use for Fortinet VMs. 'bring your own license' or 'pay as you go'"
  type        = string
  default     = "payg"
  validation {
    condition = (
      can(regex("^(byol|payg)$", var.fortinet_vm_license_type))
    )
    error_message = "Invalid license type. Options: byol|payg ."
  }
}

variable "fortigate_a_license_file" {
  description = "License file for FortiGate A VM."
  type        = string
  default     = ""
  validation {
    condition = (
      can(regex("^(|\\w*.lic)$", var.fortigate_a_license_file))
    )
    error_message = "Invalid license file. Options: \"\"|[0-9A-Za-z_]*.lic ."
  }
}

variable "fortigate_b_license_file" {
  description = "License file for FortiGate B VM."
  type        = string
  default     = ""
  validation {
    condition = (
      can(regex("^(|\\w*.lic)$", var.fortigate_b_license_file))
    )
    error_message = "Invalid license file. Options: \"\"|[0-9A-Za-z_]*.lic ."
  }
}

variable "fortigate_os_image" {
  type    = string
  default = "fortinet:fortinet_fortigate-vm_v5:fortinet_fg-vm_payg_20190624:7.0.2"
}

variable "fortigate_vm_size" {
  description = "VM Sizing for FortiGate VMs"
  type        = string
  default     = "Standard_F4s"
}

variable "fortigate_vm_username" {
  description = "Username for default FortiGate Admin user"
  type        = string
  default     = "azureuser"
}

variable "fortigate_vm_password" {
  description = "Password for default FortiGate Admin user"
  type        = string
  default     = ""
}

variable "fortiadc_a_license_file" {
  description = "License file for FortiADC A VM."
  type        = string
  default     = ""
  validation {
    condition = (
      can(regex("^(|\\w*.lic)$", var.fortiadc_a_license_file))
    )
    error_message = "Invalid license file. Options: \"\"|[0-9A-Za-z_]*.lic ."
  }
}

variable "fortiadc_b_license_file" {
  description = "License file for FortiADC B VM."
  type        = string
  default     = ""
  validation {
    condition = (
      can(regex("^(|\\w*.lic)$", var.fortiadc_b_license_file))
    )
    error_message = "Invalid license file. Options: \"\"|[0-9A-Za-z_]*.lic ."
  }
}

variable "fortiadc_os_image" {
  type    = string
  default = "fortinet:fortinet-fortiadc:fortinet-fad-vm_payg-100mbps:6.2.0"
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
