terraform {
  required_version = ">= 0.12"
}


resource "libvirt_volume" "sbd" {
  name  = "${terraform.workspace}-sbd.raw"
  pool  = var.base_configuration["pool"]
  size  = var.sbd_disk_size
  count = var.sbd_count

  xml {
    xslt = file("modules/hana_node/raw.xsl")
  }
}

module "hana_node" {
  source = "../host"

  base_configuration     = var.base_configuration
  name                   = var.name
  host_count             = var.hana_count
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  additional_repos       = var.additional_repos
  additional_packages    = var.additional_packages
  public_key_location    = var.public_key_location
  host_ips               = var.host_ips
  provisioner            = var.provisioner
  background             = var.background

  grains = <<EOF

provider: libvirt
role: hana_node
scenario_type: ${var.scenario_type}
hana_disk_device: /dev/vdb
shared_storage_type: ${var.shared_storage_type}
sbd_disk_device: "${var.shared_storage_type == "iscsi" ? "/dev/sda" : "/dev/vdc"}"
iscsi_srv_ip: ${var.iscsi_srv_ip}
hana_fstype: ${var.hana_fstype}
hana_inst_folder: ${var.hana_inst_folder}
sap_inst_media: ${var.sap_inst_media}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
EOF


  // Provider-specific variables
  memory = var.memory
  vcpu = var.vcpu
  mac = var.mac
  hana_disk_size = var.hana_disk_size

  additional_disk = slice(
    [
      {
        "volume_id" =  var.shared_storage_type == "shared-disk" ?  libvirt_volume.sbd.0.id : "null"
      },
    ],
    0,
    var.shared_storage_type == "shared-disk" ? 1 : 0,
  )
}

output "configuration" {
  value = {
    id = module.hana_node.configuration["id"]
    hostname = module.hana_node.configuration["hostname"]
  }
}

output "addresses" {
  value = {
    addresses = module.hana_node.addresses
  }
}

