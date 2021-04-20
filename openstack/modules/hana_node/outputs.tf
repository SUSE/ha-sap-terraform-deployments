data "openstack_networking_port_v2" "hana" {
  count      = local.bastion_enabled ? 0 : var.hana_count
  name       = openstack_networking_port_v2.hana[count.index].name
  depends_on = [openstack_compute_instance_v2.hana]
}

data "openstack_compute_instance_v2" "hana" {
  count      = var.hana_count
  id         = openstack_compute_instance_v2.hana[count.index].id
  depends_on = [openstack_compute_instance_v2.hana]
}

output "hana_ip" {
  value = join(",", openstack_compute_instance_v2.hana.*.access_ip_v4)
}

output "hana_public_ip" {
  value = join(",", openstack_compute_instance_v2.hana.*.access_ip_v4)
}

output "hana_name" {
  value = openstack_compute_instance_v2.hana.*.name
}

output "hana_public_name" {
  value = []
}
