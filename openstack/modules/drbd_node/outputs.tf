data "openstack_networking_port_v2" "drbd" {
  count      = local.bastion_enabled ? 0 : var.drbd_count
  name       = openstack_networking_port_v2.drbd[count.index].name
  depends_on = [openstack_compute_instance_v2.drbd]
}

data "openstack_compute_instance_v2" "drbd" {
  count      = var.drbd_count
  id         = openstack_compute_instance_v2.drbd[count.index].id
  depends_on = [openstack_compute_instance_v2.drbd]
}

output "drbd_ip" {
  value = data.openstack_compute_instance_v2.drbd.*.access_ip_v4
}

output "drbd_public_ip" {
  value = []
}

output "drbd_name" {
  value = data.openstack_compute_instance_v2.drbd.*.name
}

output "drbd_public_name" {
  value = []
}
