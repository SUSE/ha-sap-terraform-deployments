terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "my-terraform-state"
    dynamodb_table = "terraform-state-lock-dynamo"
    region         = "eu-central-1"
    key            = "state-file"
  }
}
