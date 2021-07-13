data "ibm_pi_instance" "bastion" {
  count                 = local.bastion_count
  pi_instance_name      = "${terraform.workspace}-bastion"
  pi_cloud_instance_id  = var.pi_cloud_instance_id
  # depends_on is included to avoid the issue with `resource_group was not found`.
  depends_on            = [ibm_pi_instance.bastion]
}

data "ibm_pi_instance_ip" "bastion_public" {
count                 = local.bastion_count
pi_instance_name      = "${terraform.workspace}-bastion"
pi_network_name       = join(", ", var.public_pi_network_names)
pi_cloud_instance_id  = var.pi_cloud_instance_id
# depends_on is included to avoid the issue with `resource_group was not found`.
depends_on            = [ibm_pi_instance.bastion]
}

data "ibm_pi_instance_ip" "bastion_private" {
count                 = local.bastion_count
pi_instance_name      = "${terraform.workspace}-bastion"
pi_network_name       = join(", ", var.private_pi_network_names)
pi_cloud_instance_id  = var.pi_cloud_instance_id
# depends_on is included to avoid the issue with `resource_group was not found`.
depends_on            = [ibm_pi_instance.bastion]
}


output "public_ip" {
value = join(", ", data.ibm_pi_instance_ip.bastion_public.*.external_ip)
}

output "private_ip" {
value = join(", ", data.ibm_pi_instance_ip.bastion_private.*.ip)
}
