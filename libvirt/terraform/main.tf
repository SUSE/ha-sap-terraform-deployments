provider "libvirt" {
  uri = "qemu:///system"
}

module "base" {
  source = "./modules/base"
  image = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp4.x86_64.qcow2"
  iprange = "192.168.106.0/24"

  // optional parameters below
  name_prefix = "hana"
  pool = "default"
  network_name = "default"
  timezone = "Europe/Berlin"
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
  count = 2

  vcpu = 4
  memory = 32678

  sap_inst_media = <sap_inst_media>
  hana_disk_size = "68719476736"
  host_ips = ["192.168.106.15", "192.168.106.16"]
  sbd_disk_id = "${module.sbd_disk.id}"

  additional_repos = {
    "SLE-12-SP4-x86_64-Update" = "http://download.suse.de/ibs/SUSE/Updates/SLE-SERVER/12-SP4/x86_64/update/"
    "SLE-12-SP4-x86_64-Pool" = "http://download.suse.de/ibs/SUSE/Products/SLE-SERVER/12-SP4/x86_64/product/"
    "SLE-12-SP4-x86_64-Source" = "http://download.suse.de/ibs/SUSE/Products/SLE-SERVER/12-SP4/x86_64/product_source/"
  }
}
