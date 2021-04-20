data "openstack_networking_floatingip_v2" "bastion" {
  count      = local.bastion_count
  address    = openstack_networking_floatingip_v2.bastion.0.address
  depends_on = [openstack_compute_instance_v2.bastion]
}

output "public_ip" {
  value = join("", data.openstack_networking_floatingip_v2.bastion.*.address)
}

output "bastion_ip" {
  value = join(",", openstack_networking_port_v2.bastion.0.all_fixed_ips)
}
