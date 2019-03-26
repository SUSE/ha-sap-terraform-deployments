terraform {
  required_version = "~> 0.11.7"
}

resource "libvirt_volume" "base_image" {
  name   = "${var.name_prefix}baseimage"
  source = "${var.image}"
  count  = "${var.use_shared_resources ? 0 : 1}"
  pool   = "${var.pool}"
}

resource "libvirt_network" "isolated_network" {
  name      = "${var.name_prefix}-isolated"
  mode      = "none"
  addresses = ["${var.iprange}"]

  dhcp {
    enabled = "false"
  }

  autostart = true
}

output "configuration" {
  depends_on = [
    "libvirt_volume.base_image",
    "libvirt_network.isolated_network",
  ]

  value = {
    timezone             = "${var.timezone}"
    public_key_location  = "${var.public_key_location}"
    domain               = "${var.domain}"
    name_prefix          = "${var.name_prefix}"
    use_shared_resources = "${var.use_shared_resources}"
    isolated_network_id  = "${join(",", libvirt_network.isolated_network.*.id)}"
    iprange              = "${var.iprange}"

    // Provider-specific variables
    pool         = "${var.pool}"
    network_name = "${var.bridge == "" ? var.network_name : ""}"
    bridge       = "${var.bridge}"
  }
}
