provider "google" {
  credentials = "${file("${var.gcp_credentials_file}")}"
  project     = "suse-css-qa"
  region      = "${var.region}"
  zone        = "${var.zone}"
}
