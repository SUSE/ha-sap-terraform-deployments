resource "null_resource" "nfs_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.nfs_pool_count : 0
  triggers = {
    nfs_pool_ids = libvirt_domain.nfs_server_domain[count.index].id
  }

  connection {
    host     = libvirt_domain.nfs_server_domain[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    content     = <<EOF
role: nfs_pool
${var.common_variables["grains_output"]}
name_prefix: ${var.common_variables["deployment_name"]}-${var.name}
hostname: ${var.common_variables["deployment_name"]}-${var.name}
timezone: ${var.timezone}
network_domain: ${var.network_domain}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
nfs_mounting_point: ${var.nfs_mounting_point}
nfs_export_name: ${var.nfs_export_name}
EOF
    destination = "/tmp/grains"
  }
}

module "nfs_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.common_variables["provisioner"] == "salt" ? var.nfs_pool_count : 0
  instance_ids = null_resource.nfs_provisioner.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.nfs_server_domain.*.network_interface.0.addresses.0
  background   = var.common_variables["background"]
}
