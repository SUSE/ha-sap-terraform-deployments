variable "qemu_uri" {
	description = "URI to connect with the qemu-service."
	default = "qemu:///system"
}

variable "base_image" {
  description = "Image of the sap hana nodes"
  default = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp4.x86_64.qcow2"
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

variable "additional_repos" {
  description = "Map of the repositories to add to the images. Repo name = url"
  default = {
    "SLE-12-SP4-x86_64-Update" = "http://download.suse.de/ibs/SUSE/Updates/SLE-SERVER/12-SP4/x86_64/update/"
    "SLE-12-SP4-x86_64-Pool" = "http://download.suse.de/ibs/SUSE/Products/SLE-SERVER/12-SP4/x86_64/product/"
    "SLE-12-SP4-x86_64-Source" = "http://download.suse.de/ibs/SUSE/Products/SLE-SERVER/12-SP4/x86_64/product_source/"
		"SUSE_Updates_SLE-HA_12-SP3" =  "http://download.suse.de/ibs/SUSE/Products/SLE-HA/12-SP3/x86_64/product/"
		"SAPHanaSR-Pool" =  "http://download.suse.de/ibs/SUSE:/SLE-12-SP3:/Update/standard/"
	}
}
