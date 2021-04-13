data "openstack_networking_port_v2" "netweaver" {
  count      = local.bastion_enabled ? 0 : local.vm_count
  name       = openstack_networking_port_v2.netweaver[count.index].name
  depends_on = [openstack_compute_instance_v2.netweaver]
}

data "openstack_compute_instance_v2" "netweaver" {
  count      = local.vm_count
  id         = openstack_compute_instance_v2.netweaver[count.index].id
  depends_on = [openstack_compute_instance_v2.netweaver]
}

output "netweaver_ip" {
  value = join(",", openstack_compute_instance_v2.netweaver.*.access_ip_v4)
}

output "netweaver_public_ip" {
  value = join(",", openstack_compute_instance_v2.netweaver.*.access_ip_v4)
}

output "netweaver_name" {
  value = openstack_compute_instance_v2.netweaver.*.name
}

output "netweaver_public_name" {
  value = []
}
