resource "google_storage_bucket" "terraform-state" {
  # NOTE: The bucket name must be globally unique and conform to certain requirements described in:
  # https://cloud.google.com/storage/docs/naming#requirements
  name = "terraform-state"

  location = "eu"
  project  = "my-project"

  versioning {
    enabled = true
  }
}
