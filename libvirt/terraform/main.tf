provider "libvirt" {
  uri = "${var.qemu_uri}"
}

module "base" {
  source = "./modules/base"
  image = "${var.base_image}"
  iprange = "${var.iprange}"

  // optional parameters below
  name_prefix = "${var.name_prefix}"
  // pool = "default"
  pool = "terraform"
  // network_name = "default"
  network_name = ""
  bridge = "br0"
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

  sap_inst_media = "${var.sap_inst_media}"
  ntp_server = "pool.ntp.org"
  hana_disk_size = "68719476736"
  host_ips = "${var.host_ips}"
  sbd_disk_id = "${module.sbd_disk.id}"

  # Set proper ssh file. The default files are public in github
  # Copy custom files in salt/hana_node/file/sshkeys
  cluster_ssh_pub = "${var.cluster_ssh_pub}"
  cluster_ssh_key = "${var.cluster_ssh_key}"

  additional_repos = "${var.additional_repos}"
}
