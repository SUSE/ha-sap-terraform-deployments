variable "cluster_id" {
	description = "This is the ID for distinguishing cluster resources."
	type = "string"
}

variable "count" {
	description = "This is the number of nodes to be set up."
	type = "string"
}

variable "os_image" {
	description = "This is the location of the operating system image disk."
	type = "string"
}

variable "image_pool" {
	description = "This is the pool where the disk images shall be stored."
	type = "string"

}

variable "rep_disk_size" {
	description = "The size of the replication disk attached to the node"
	type = "string"
}

variable "vcpu" {
	description = "This is the number of CPU cores assigned to one node."
	type = "string"
}

variable "arch" {
	description = "This is the desired CPU ISA of the node."
	type = "string"
}

variable "memory" {
	description = "This is the RAM size assigned to each node."
	type = "string"
}

variable "cluster_net_id" {
	description = "The name of the created cluster network."
	type = "string"
}

variable "cluster_net_ip" {
	description = "This is the cluster network IP address."
	type = "string"
}

variable "nat_net_id" {
	description = "The name of the created cluster network."
	type = "string"
}

variable "nat_net_ip" {
	description = "This is the cluster network IP address."
	type = "string"
}

/*
 *variable "stonith_disk_id" {
 *	description = "This is the ID of the sbd disk."
 *	type = "string"
 *}
 */
