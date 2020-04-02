variable "node_count" {
  description = "Number of nodes to run the provisioner"
  type        = number
}

variable "instance_ids" {
  description = "List with the instance ids that will trigger the provisioner"
  type        = list(string)
}

variable "user" {
  description = "User for the SSH connection"
  type        = string
  default     = "root"
}

variable "password" {
  description = "Password for the SSH connection"
  type        = string
  default     = ""
}

variable "private_key_location" {
  description = "SSH private key for the connection. It has priority over password variable"
  type        = string
  default     = ""
}

variable "public_ips" {
  description = "List of ips used to connect through SSH"
  type        = list(string)
}

variable "dependencies" {
  description = "List of resources that are needed to create the SSH connection"
  type        = any
  default     = []
}
