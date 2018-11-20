resource "libvirt_network" "net" {
	name = "net_${var.mode}-${var.cluster_id}"
	addresses = ["${var.net_ip}"]
	mode = "${var.mode}"
	bridge = "${var.bridge}"
	dhcp { enabled = true }
	autostart = true
}
