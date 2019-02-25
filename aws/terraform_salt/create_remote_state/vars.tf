variable "aws_region" {
  type    = "string"
  default = "eu-central-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  default     = "my-terraform-state"
}

variable "dynamodb_name" {
  description = "The name of the DynamoDB table."
  default     = "terraform-state-lock-dynamo"
}
