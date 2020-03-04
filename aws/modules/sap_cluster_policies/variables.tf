variable "enabled" {
  type        = bool
  description = "Enable the sap cluster policies creation"
}

variable "name" {
  type        = string
  description = "Name used to create the role and policies. It will be attached after the workspace"
}

variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type        = string
  description = "AWS account id (12 digit id available to the right of the user in the AWS portal)"
}

variable "cluster_instances" {
  type        = list(string)
  description = "Instances that will be attached to the role"
}

variable "route_table_id" {
  type        = string
  description = "Route table id"
}
