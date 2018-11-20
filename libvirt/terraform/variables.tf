#___________________________Libvirt/QEMU Settings______________________________#
# This section specifies variables influencing the Libvirt/QEMU settings.      #

variable "qemu_uri" {
	description = "This is the URI for connection with the qemu-service."
	default = "qemu:///system"
}

variable "image_pool" {
	description = "This is the disk image pool that shall be used."
	default = "default"
}

variable "nat_net_ip" {
	description = "This is the NAT to Libvirt host network IP address."
	default = "192.168.0.0/24"
}

#_____________________________Cluster Settings_________________________________#
# This section specifies variables influencing cluster attributes.             #

variable "cluster_id" {
	description = "This distinguishes cluster setups. Do change the value!"
	default = "foo_bar" # 8 chars max!
}

variable "cluster_net_ip" {
	description = "This is the cluster network IP address."
	default = "192.168.101.0/24"
}

variable "number_of_nodes" {
	description = "This is the number of cluster nodes to be set up."
	default = 2
}

variable "stonith_disk_size" {
	description = "This is the size of the voting disk (SBD) in Bytes"
	default = "104857600"
}

#_______________________________Node Settings__________________________________#
# This section specifies variables influencing the cluster node attributes.    #

variable "node_number_of_cpus" {
	description = "This is the number of CPU cores assigned to the node"
	default = "1"
}

variable "node_isa" {
	description = "This is the desired instruction set architecture (ISA)"
	default = "x86_64"
}

variable "node_ram_size" {
	description = "This is the RAM size assigned to the node in MiB"
	default = "512"
}

variable "os_image" {
	description = "This URL specifies the location of the OS image."
	default = "https://download.opensuse.org/repositories/systemsmanagement:/sumaform:/images:/libvirt/images/opensuse150.x86_64-0.1.0-Buildlp150.1.1.qcow2"
}

variable "node_replication_disk_size" {
	description = "This is the size of the HANA DB disk of nodes in Bytes"
	default = "64424509440"
}

/* SSH keys reside in the path ~/.ssh. As an example, when you have an ed25519
key instead, you may change this variable to id_ed25519.pub. */
variable "ssh_key_file" {
	description = "Name of file containing your public SSH key."
	default = "id_rsa.pub"
}
