resource "null_resource" "majority_maker_provisioner" {
  count = var.common_variables["provisioner"] == "salt" && var.majority_maker_enabled ? 1 : 0
  triggers = {
    majority_maker_id = libvirt_domain.majority_maker_domain.0.id
  }

  connection {
    host     = libvirt_domain.majority_maker_domain.0.network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    content     = <<EOF
role: majority_maker_node
${var.common_variables["grains_output"]}
name_prefix: ${var.name}
hostname: ${var.name}0${length(var.cluster_ips) + 1}
timezone: ${var.timezone}
network_domain: ${var.network_domain}
host_ips: [${join(", ", formatlist("'%s'", concat(var.cluster_ips, [var.majority_maker_ip])))}]
host_ip: ${var.majority_maker_ip}
public_ip: ${libvirt_domain.majority_maker_domain[0].network_interface[0].addresses[0]}
sbd_enabled: ${var.sbd_enabled}
sbd_storage_type: ${var.sbd_storage_type}
sbd_disk_device: "${var.sbd_storage_type == "shared-disk" ? "/dev/vdc" : ""}"
sbd_lun_index: 0
iscsi_srv_ip: ${var.iscsi_srv_ip}
cluster_ssh_pub: salt://sshkeys/cluster.id_rsa.pub
cluster_ssh_key: salt://sshkeys/cluster.id_rsa
EOF
    destination = "/tmp/grains"
  }
}

module "majority_maker_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.common_variables["provisioner"] == "salt" && var.majority_maker_enabled ? 1 : 0
  instance_ids = null_resource.majority_maker_provisioner.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.majority_maker_domain.*.network_interface.0.addresses.0
  background   = var.common_variables["background"]
}