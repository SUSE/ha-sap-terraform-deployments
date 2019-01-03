terraform {
    required_version = "~> 0.11.7"
}


resource "libvirt_volume" "sles15_volume" {
  name = "${var.name_prefix}sles15"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles15") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles11sp4_volume" {
  name = "${var.name_prefix}sles11sp4"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp4.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles11sp4") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12_volume" {
  name = "${var.name_prefix}sles12"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp1_volume" {
  name = "${var.name_prefix}sles12sp1"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp1.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp1") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp2_volume" {
  name = "${var.name_prefix}sles12sp2"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp2.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp2") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp3_volume" {
  name = "${var.name_prefix}sles12sp3"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp3.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp3") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_volume" "sles12sp4_volume" {
  name = "${var.name_prefix}sles12sp4"
  source = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp4.x86_64.qcow2"
  count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp4") ? 1 : 0)}"
  pool = "${var.pool}"
}

resource "libvirt_network" "additional_network" {
  count = "${var.additional_network ? 1 : 0}"
  name = "${var.name_prefix}-private"
  mode = "none"
  addresses = [ "${var.iprange}" ]
  dhcp { enabled = true }
  autostart = true
}

output "configuration" {
  depends_on = [
    "libvirt_volume.sles15_volume",
    "libvirt_volume.sles11sp4_volume",
    "libvirt_volume.sles12_volume",
    "libvirt_volume.sles12sp1_volume",
    "libvirt_volume.sles12sp2_volume",
    "libvirt_volume.sles12sp3_volume",
    "libvirt_volume.sles12sp4_volume",
    "libvirt_network.additional_network"
  ]
  value = {
    timezone = "${var.timezone}"
    ssh_key_path = "${var.ssh_key_path}"
    domain = "${var.domain}"
    name_prefix = "${var.name_prefix}"
    use_shared_resources = "${var.use_shared_resources}"
    additional_network = "${var.additional_network}"
    additional_network_id = "${join(",", libvirt_network.additional_network.*.id)}"
    iprange = "${var.iprange}"

    // Provider-specific variables
    pool = "${var.pool}"
    network_name = "${var.bridge == "" ? var.network_name : ""}"
    bridge = "${var.bridge}"
  }
}
