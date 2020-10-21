variable "common_variables" {
  description = "Output of the common_variables module"
}

variable "enabled" {
  description = "Enable the sap cluster policies creation"
  type        = bool
}

variable "name" {
  type        = string
  description = "Name used to create the role and policies. It will be attached after the workspace"
}

variable "aws_region" {
  type = string
}

variable "cluster_instances" {
  type        = list(string)
  description = "Instances that will be attached to the role"
}

variable "route_table_id" {
  type        = string
  description = "Route table id"
}
