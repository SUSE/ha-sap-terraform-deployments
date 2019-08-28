
//resource "libvirt_volume" "base_image" {
//  name   = "${terraform.workspace}-baseimage"
//  source = var.image
//  count  = var.use_shared_resources ? 0 : 1
// pool   = var.pool
//}

output "configuration" {
  depends_on = [
    libvirt_volume.base_image,
  ]

  value = {
    timezone             = var.timezone
    public_key_location  = var.public_key_location
    domain               = var.domain
    // Provider-specific variables
    pool         = var.pool
    network_name = var.bridge == "" ? var.network_name : ""
    bridge       = var.bridge
  }
}

