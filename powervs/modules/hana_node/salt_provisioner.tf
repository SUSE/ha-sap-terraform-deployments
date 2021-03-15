resource "null_resource" "hana_node_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0

  triggers = {
    hana_ids = ibm_pi_instance.ibm_pi_hana[count.index].instance_id
  }

  connection {
  host        = ibm_pi_instance.ibm_pi_hana[count.index].addresses.0.external_ip
  type        = "ssh"
  user        = var.common_variables["authorized_user"]
  private_key = var.common_variables["private_key"]
  }

  provisioner "file" {
    content     = <<EOF
role: hana_node
${var.common_variables["grains_output"]}
${var.common_variables["hana_grains_output"]}
name_prefix: ${terraform.workspace}-${var.name}
hostname: ${terraform.workspace}-${var.name}0${count.index + 1}
host_ips: [${join(",", data.ibm_pi_instance.ibm_pi_hana[*].addresses[0].ip)}]
network_domain: "tf.local"
hana_data_disks_configuration: {${join(", ", formatlist("'%s': '%s'", keys(var.hana_data_disks_configuration), values(var.hana_data_disks_configuration), ), )}}
hana_data_disks_wwn: {${join(", ", formatlist("'%s': '%s'", join(",", data.ibm_pi_instance.ibm_pi_hana[*].pi_instance_name), lower(join(",", data.ibm_pi_volume.ibm_pi_hana_volume[*].wwn))))}}
EOF
    destination = "/tmp/grains"
  }
}

module "hana_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0
  instance_ids = null_resource.hana_node_provisioner.*.id
  user         = var.common_variables["authorized_user"]
  private_key  = var.common_variables["private_key"]
  public_ips   = ibm_pi_instance.ibm_pi_hana.*.addresses.0.external_ip
  background   = var.common_variables["background"]
}
