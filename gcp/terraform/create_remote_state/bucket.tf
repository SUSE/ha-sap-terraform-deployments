resource "google_storage_bucket" "terraform-state" {
  # NOTE: The bucket name must be globally unique and conform to certain requirements described in:
  # https://cloud.google.com/storage/docs/naming#requirements
  name = "terraform-state-suse-css-qa"

  location = "eu"
  project  = "suse-css-qa"

  versioning {
    enabled = true
  }
}
