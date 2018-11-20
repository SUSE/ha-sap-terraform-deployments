resource "libvirt_volume" "root_disk" {
	name = "${var.cluster_id}-node${count.index + 1}-root_disk.qcow2"
	pool = "default"
	source = "${var.os_image}"

	count = "${var.count}"
}

resource "libvirt_volume" "rep_disk" {
	name = "${var.cluster_id}-node${count.index + 1}-rep_disk.qcow2"
	pool = "default"
	size = "${var.rep_disk_size}"

	count = "${var.count}"
}

resource "libvirt_domain" "node" {
	name = "${var.cluster_id}-node${count.index + 1}"
	vcpu = "${var.vcpu}"
	arch = "${var.arch}"
	memory = "${var.memory}"

	network_interface {
		network_id = "${var.nat_net_id}"
		addresses = ["${cidrhost(var.nat_net_ip, count.index + 11)}"]
		#mac = "52:54:00:b2:2f:${format("%02d", count.index + 1)}"
	}

	network_interface {
		hostname = "node${format("%02d", count.index + 1)}"
		network_id = "${var.cluster_net_id}"
		addresses = ["${cidrhost(var.cluster_net_ip, count.index + 11)}"]
		#mac = "52:54:00:b2:2e:${format("%02d", count.index + 1)}"
	}

	disk {
		volume_id = "${element(libvirt_volume.root_disk.*.id, count.index)}"
	}

	disk {
		volume_id = "${element(libvirt_volume.rep_disk.*.id, count.index)}"
	}

	/* disk {
	 *	volume_id = "${var.stonith_disk_id}"
	 *}
	 */

	count = "${var.count}"
}
