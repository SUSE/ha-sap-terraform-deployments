terraform {
  required_version = ">= 1.1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.10.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

# Configure the GCP Provider
provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.project
  region      = var.region
}
