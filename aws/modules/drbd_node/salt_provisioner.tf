resource "null_resource" "drbd_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.drbd_count : 0

  triggers = {
    drbd_id = join(",", aws_instance.drbd.*.id)
  }

  connection {
    host        = element(aws_instance.drbd.*.public_ip, count.index)
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.common_variables["private_key_location"])
  }

  provisioner "file" {
    source      = var.aws_access_key_id == "" || var.aws_secret_access_key == "" ? var.aws_credentials : "/dev/null"
    destination = "/tmp/credentials"
  }

  provisioner "file" {
    content     = <<EOF
role: drbd_node
${var.common_variables["grains_output"]}
region: ${var.aws_region}
name_prefix: ${var.name}
aws_cluster_profile: Cluster
aws_instance_tag: ${terraform.workspace}-cluster
aws_credentials_file: /tmp/credentials
aws_access_key_id: ${var.aws_access_key_id}
aws_secret_access_key: ${var.aws_secret_access_key}
hostname: ${var.name}0${count.index + 1}
network_domain: ${var.network_domain}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
fencing_mechanism: ${var.fencing_mechanism}
drbd_disk_device: /dev/xvdd
drbd_cluster_vip: ${var.drbd_cluster_vip}
route_table: ${var.route_table_id}
shared_storage_type: iscsi
sbd_lun_index: 2
iscsi_srv_ip: ${var.iscsi_srv_ip}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
nfs_mounting_point: ${var.nfs_mounting_point}
nfs_export_name: ${var.nfs_export_name}
partitions:
  1:
    start: 0%
    end: 100%
EOF
    destination = "/tmp/grains"
  }
}

module "drbd_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.common_variables["provisioner"] == "salt" ? var.drbd_count : 0
  instance_ids         = null_resource.drbd_provisioner.*.id
  user                 = "ec2-user"
  private_key_location = var.common_variables["private_key_location"]
  public_ips           = aws_instance.drbd.*.public_ip
  background           = var.common_variables["background"]
}
