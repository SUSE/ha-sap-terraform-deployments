terraform {
  backend "gcs" {
    bucket = "terraform-state-suse-css-qa"
    prefix = "terraform/state"
  }
}
