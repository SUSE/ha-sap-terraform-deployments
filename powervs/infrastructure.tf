terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "> 1.21"
    }
  }
  required_version = ">= 0.13"
}

locals {
  deployment_name = var.deployment_name != "" ? var.deployment_name : terraform.workspace
}
