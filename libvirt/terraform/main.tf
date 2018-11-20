provider "libvirt" {
	alias = "qemuhost"
	uri = "${var.qemu_uri}"
}

module "nat_net" {
	source = "network"
	net_ip = "${var.nat_net_ip}"
	mode = "nat"
	bridge = "virbr-${var.cluster_id}1"
	cluster_id = "${var.cluster_id}"
}

module "cluster_net" {
	source = "network"
	net_ip = "${var.cluster_net_ip}"
	mode = "none"
	bridge = "virbr-${var.cluster_id}2"
	cluster_id = "${var.cluster_id}"
}

resource "libvirt_volume" "os_image" {
	name = "os_image-${var.cluster_id}.qcow2"
	source = "${var.os_image}"
	pool = "default"
}

/*
 * resource "libvirt_volume" "stonith_disk" {
 *	provider = "libvirt.qemuhost"
 *	name = "sbd-${var.cluster_id}.raw"
 *	pool = "default"
 *	format = "raw"
 *	size = "${var.stonith_disk_size}"
 *}
 */

module "cluster_nodes" {
	cluster_net_ip = "${var.cluster_net_ip}"
	cluster_net_id = "${module.cluster_net.id}"
	nat_net_ip = "${var.nat_net_ip}"
	nat_net_id = "${module.nat_net.id}"
	cluster_id = "${var.cluster_id}"
	source = "node"
	count = "${var.number_of_nodes}"
	os_image = "${var.os_image}"
	image_pool = "${var.image_pool}"
	vcpu = "${var.node_number_of_cpus}"
	arch = "${var.node_isa}"
	memory = "${var.node_ram_size}"
	rep_disk_size = "${var.node_replication_disk_size}"
	/* stonith_disk_id = "${libvirt_volume.stonith_disk.id}" */
}
