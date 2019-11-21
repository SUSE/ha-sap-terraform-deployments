module "drbd_node" {
  source                 = "./modules/drbd_node"
  drbd_count             = var.drbd_enabled == true ? 2 : 0
  resource_group_name    = azurerm_resource_group.myrg.name
  network_subnet_id      = azurerm_subnet.mysubnet.id
  sec_group_id           = azurerm_network_security_group.mysecgroup.id
  availability_set_id    = azurerm_availability_set.myas.id
  storage_account        = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  public_key_location    = "/home/xarbulu/.ssh/id_rsa_cloud.pub"
  private_key_location   = "/home/xarbulu/.ssh/id_rsa_cloud"
  cluster_ssh_pub        = var.cluster_ssh_pub
  cluster_ssh_key        = var.cluster_ssh_key
  admin_user             = var.admin_user
  host_ips               = var.drbd_ips
  iscsi_srv_ip           = azurerm_network_interface.iscsisrv.private_ip_address
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  devel_mode             = var.devel_mode
  provisioner            = var.provisioner
  background             = var.background
  monitoring_enabled     = var.monitoring_enabled
}
