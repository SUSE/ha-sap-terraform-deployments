output "id" {
	depends_on = [ "libvirt_network.net" ]
	value ="${libvirt_network.net.id}"
}
