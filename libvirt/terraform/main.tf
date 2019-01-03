provider "libvirt" {
  uri = "qemu:///system"
}

module "base" {
  source = "./modules/base"

  images = ["sles12sp4"]

  // optional parameters with defaults below
  name_prefix = "xarbuluhana"
  // pool = "default"
  pool = "terraform"
  // network_name = "default"
  network_name = ""
  bridge = "br0"
  timezone = "Europe/Berlin"
  additional_network = true
  iprange = "192.168.106.0/24"
}

module "sbd_disk" {
  source = "./modules/sbd"
  base_configuration = "${module.base.configuration}"
  sbd_disk_size = "104857600"
}

module "hana_node" {
  source = "./modules/hana_node"
  base_configuration = "${module.base.configuration}"
  // hana01 and hana02

  name = "hana"
  image = "sles12sp4"
  count = 2
  hana_disk_size = "68719476736"
  host_ips = ["192.168.102.15", "192.168.102.16"]
  sbd_disk_id = "${module.sbd_disk.id}"

  additional_repos = {
    "SLE-12-SP4-x86_64-Update" = "http://download.suse.de/ibs/SUSE/Updates/SLE-SERVER/12-SP4/x86_64/update/"
    "SLE-12-SP4-x86_64-Pool" = "http://download.suse.de/ibs/SUSE/Products/SLE-SERVER/12-SP4/x86_64/product/"
    "SLE-12-SP4-x86_64-Source" = "http://download.suse.de/ibs/SUSE/Products/SLE-SERVER/12-SP4/x86_64/product_source/"
  }
}
