data "openstack_networking_port_v2" "monitoring" {
  count      = local.bastion_enabled ? 0 : local.vm_count
  name       = openstack_networking_port_v2.monitoring[count.index].name
  depends_on = [openstack_compute_instance_v2.monitoring]
}

data "openstack_compute_instance_v2" "monitoring" {
  count      = local.vm_count
  id         = openstack_compute_instance_v2.monitoring[count.index].id
  depends_on = [openstack_compute_instance_v2.monitoring]
}

output "monitoring_ip" {
  value = join(",", openstack_compute_instance_v2.monitoring.*.access_ip_v4)
}

output "monitoring_public_ip" {
  value = join(",", openstack_compute_instance_v2.monitoring.*.access_ip_v4)
}

output "monitoring_name" {
  value = openstack_compute_instance_v2.monitoring.*.name
}

output "monitoring_public_name" {
  value = []
}
