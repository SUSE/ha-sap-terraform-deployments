provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.project
  region      = var.region
}

data "google_compute_zones" "available" {
  region = var.region
  status = "UP"
}

