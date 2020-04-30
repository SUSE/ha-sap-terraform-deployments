resource "null_resource" "drbd_provisioner" {
  count = var.provisioner == "salt" ? var.drbd_count : 0

  triggers = {
    drbd_id = join(",", aws_instance.drbd.*.id)
  }

  connection {
    host        = element(aws_instance.drbd.*.public_ip, count.index)
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source      = var.aws_access_key_id == "" || var.aws_secret_access_key == "" ? var.aws_credentials : "/dev/null"
    destination = "/tmp/credentials"
  }

  provisioner "file" {
    content     = <<EOF
provider: aws
region: ${var.aws_region}
role: drbd_node
name_prefix: ${var.name}
aws_cluster_profile: Cluster
aws_instance_tag: ${terraform.workspace}-cluster
hostname: ${var.name}0${count.index + 1}
network_domain: ${var.network_domain}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
drbd_disk_device: /dev/sdc
drbd_cluster_vip: ${var.drbd_cluster_vip}
route_table: ${var.route_table_id}
shared_storage_type: iscsi
sbd_disk_index: 3
iscsi_srv_ip: ${var.iscsi_srv_ip}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
devel_mode: ${var.devel_mode}
qa_mode: ${var.qa_mode}
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
  node_count           = var.provisioner == "salt" ? var.drbd_count : 0
  instance_ids         = null_resource.drbd_provisioner.*.id
  user                 = "ec2-user"
  private_key_location = var.private_key_location
  public_ips           = aws_instance.drbd.*.public_ip
  background           = var.background
}
