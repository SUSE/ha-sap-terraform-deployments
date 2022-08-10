data "openstack_networking_port_v2" "nfssrv" {
  count      = local.bastion_enabled ? 0 : var.nfs_count
  name       = element(openstack_networking_port_v2.nfssrv.*.name, count.index)
  depends_on = [openstack_compute_instance_v2.nfssrv]
}

data "openstack_compute_instance_v2" "nfssrv" {
  count      = var.nfs_count
  id         = element(openstack_compute_instance_v2.nfssrv.*.id, count.index)
  depends_on = [openstack_compute_instance_v2.nfssrv]
}

output "nfs_ip" {
  value = join(",", openstack_compute_instance_v2.nfssrv.*.access_ip_v4)
}

output "nfs_public_ip" {
  value = join(",", openstack_compute_instance_v2.nfssrv.*.access_ip_v4)
}

output "nfs_name" {
  value = openstack_compute_instance_v2.nfssrv.*.name
}

output "nfs_public_name" {
  value = openstack_compute_instance_v2.nfssrv.*.name
}
