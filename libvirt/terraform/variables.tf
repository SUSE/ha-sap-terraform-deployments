variable "qemu_uri" {
	description = "URI to connect with the qemu-service."
	default = "qemu:///system"
}

variable "base_image" {
  description = "Image of the sap hana nodes"
	type = "string"
}

variable "iprange" {
  description = "IP range of the isolated network"
  default = "192.168.106.0/24"
}

variable "name_prefix" {
  description = "Prefix of the deployment VM, network and disks"
  default = "hanatest"
}

variable "sap_inst_media" {
  description = "URL of the NFS share where the SAP software installer is stored. This media shall be mounted in /root/sap_inst"
  type = "string"
}

variable "host_ips" {
  description = "IP addresses of the nodes"
  default = ["192.168.106.15", "192.168.106.16"]
}

variable "ntp_server" {
  description = "ntp server address. Let empty to not setup any ntp server"
  default = ""
}

variable "additional_repos" {
  description = "Map of the repositories to add to the images. Repo name = url"
	type = "map"
}
