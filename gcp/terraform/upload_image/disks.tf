resource "google_storage_bucket" "sle_image_store" {
  name          = "${var.images_path_bucket}"
  location      = "${var.region}"
  force_destroy = true
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_object" "sles_os_image_file" {
  name   = "${var.sles_os_image_file}"
  source = "${var.images_path}/${var.sles_os_image_file}"
  bucket = "${var.images_path_bucket}"
}

resource "google_storage_bucket_object" "sles4sap_os_image_file" {
  name   = "${var.sles4sap_os_image_file}"
  source = "${var.images_path}/${var.sles4sap_os_image_file}"
  bucket = "${var.images_path_bucket}"
}
