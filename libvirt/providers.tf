terraform {
  required_version = ">= 1.0.8"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.6.11"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

provider "libvirt" {
  uri = var.qemu_uri
}
