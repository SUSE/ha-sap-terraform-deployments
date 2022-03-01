# using the libvirt prodider requires a terraform block every submodule
# keep in mind also to change every terraform block in modules/*/main.tf

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

provider "libvirt" {
  uri = var.qemu_uri
}
