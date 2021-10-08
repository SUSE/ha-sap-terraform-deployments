terraform {
  required_version = ">= 1.0.8"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.87.0"
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
