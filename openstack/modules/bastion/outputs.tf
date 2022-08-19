data "openstack_networking_floatingip_v2" "bastion" {
  count      = local.bastion_count
  address    = openstack_networking_floatingip_v2.bastion.0.address
  depends_on = [openstack_compute_instance_v2.bastion]
}

data "openstack_compute_instance_v2" "bastion" {
  count      = local.bastion_count
  id         = openstack_compute_instance_v2.bastion.0.id
  depends_on = [openstack_compute_instance_v2.bastion]
}

output "public_ip" {
  value = join("", data.openstack_networking_floatingip_v2.bastion.*.address)
}

output "bastion_ip" {
  value = data.openstack_compute_instance_v2.bastion.*.access_ip_v4
}
