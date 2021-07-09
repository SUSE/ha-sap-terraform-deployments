data "ibm_pi_instance" "ibm_pi_hana" {
  count                 = var.hana_count
  pi_instance_name      = "${terraform.workspace}-${var.name}0${count.index + 1}"
  pi_cloud_instance_id  = var.pi_cloud_instance_id
  # depends_on is included to avoid the issue with `resource_group was not found`.
  depends_on            = [ibm_pi_instance.ibm_pi_hana]
}

data "ibm_pi_volume" "ibm_pi_hana_volume" {
  count                = var.hana_count * local.disks_number
  pi_volume_name      = "${terraform.workspace}-${var.name}-volume${count.index + 1}"
  pi_cloud_instance_id  = var.pi_cloud_instance_id
  # depends_on is included to avoid the issue with `resource_group was not found`.
  depends_on            = [ibm_pi_volume.ibm_pi_hana_volume]
}

data "ibm_pi_instance_ip" "ibm_pi_hana_private" {
count                 = var.hana_count
pi_instance_name      = "${terraform.workspace}-${var.name}0${count.index + 1}"
pi_network_name      = join(", ", var.private_pi_network_names)
pi_cloud_instance_id  = var.pi_cloud_instance_id
# depends_on is included to avoid the issue with `resource_group was not found`.
depends_on            = [ibm_pi_instance.ibm_pi_hana]
}

data "ibm_pi_instance_ip" "ibm_pi_hana_public" {
count                 = var.hana_count
pi_instance_name      = "${terraform.workspace}-${var.name}0${count.index + 1}"
pi_network_name      = join(", ", var.public_pi_network_names)
pi_cloud_instance_id  = var.pi_cloud_instance_id
# depends_on is included to avoid the issue with `resource_group was not found`.
depends_on            = [ibm_pi_instance.ibm_pi_hana]
}

output "cluster_nodes_ip" {
value = join(", ", data.ibm_pi_instance_ip.ibm_pi_hana_private.*.ip)
}

output "cluster_nodes_public_ip" {
value = local.bastion_enabled ? "" : join(", ", data.ibm_pi_instance_ip.ibm_pi_hana_private.*.external_ip)
}

# debug - can contain temporary outputs of values for debugging purposes

#output "provisioning_addresses" {
#value = local.provisioning_addresses
#}
