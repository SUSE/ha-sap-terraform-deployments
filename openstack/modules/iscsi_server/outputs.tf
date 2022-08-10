data "openstack_networking_port_v2" "iscsisrv" {
  count      = local.bastion_enabled ? 0 : var.iscsi_count
  name       = element(openstack_networking_port_v2.iscsisrv.*.name, count.index)
  depends_on = [openstack_compute_instance_v2.iscsisrv]
}

data "openstack_compute_instance_v2" "iscsisrv" {
  count      = var.iscsi_count
  id         = element(openstack_compute_instance_v2.iscsisrv.*.id, count.index)
  depends_on = [openstack_compute_instance_v2.iscsisrv]
}

output "iscsi_ip" {
  value = join(",", openstack_compute_instance_v2.iscsisrv.*.access_ip_v4)
  # value = data.openstack_compute_instance_v2.iscsisrv.*.access_ip_v4
}

output "iscsi_public_ip" {
  value = join(",", openstack_compute_instance_v2.iscsisrv.*.access_ip_v4)
  # value = data.openstack_compute_instance_v2.iscsisrv.*.access_ip_v4
}

output "iscsi_name" {
  # value = join(",",openstack_compute_instance_v2.iscsisrv.*.name)
  value = openstack_compute_instance_v2.iscsisrv.*.name
}

output "iscsi_public_name" {
  # value = []
  value = openstack_compute_instance_v2.iscsisrv.*.name
}
