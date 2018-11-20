variable "net_ip" {
	description = "This is the network IP address."
	type = "string"
}

variable "mode" {
	description = "This is the mode of the network."
	type = "string"
}

variable "bridge" {
	description = "This is the bridge interface to be used for the network."
	type = "string"
}

variable "cluster_id" {
	description = "This is the user ID owning the network."
	type = "string"
}
