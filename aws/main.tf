module "local_execution" {
  source  = "../generic_modules/local_exec"
  enabled = var.pre_deployment
}

module "netweaver_node" {
  source                    = "./modules/netweaver_node"
  netweaver_count           = var.netweaver_enabled == true ? 4 : 0
  instancetype              = var.netweaver_instancetype
  name                      = "netweaver"
  aws_account_id            = var.aws_account_id
  aws_region                = var.aws_region
  availability_zones        = data.aws_availability_zones.available.names
  sles4sap_images           = var.sles4sap
  vpc_id                    = aws_vpc.vpc.id
  vpc_cidr_block            = aws_vpc.vpc.cidr_block
  key_name                  = aws_key_pair.hana-key-pair.key_name
  security_group_id         = aws_security_group.secgroup.id
  route_table_id            = aws_route_table.route-table.id
  efs_performance_mode      = var.netweaver_efs_performance_mode
  aws_credentials           = var.aws_credentials
  aws_access_key_id         = var.aws_access_key_id
  aws_secret_access_key     = var.aws_secret_access_key
  s3_bucket                 = var.netweaver_s3_bucket
  netweaver_product_id      = var.netweaver_product_id
  netweaver_swpm_folder     = var.netweaver_swpm_folder
  netweaver_sapexe_folder   = var.netweaver_sapexe_folder
  netweaver_additional_dvds = var.netweaver_additional_dvds
  hana_ip                   = var.hana_cluster_vip
  host_ips                  = var.netweaver_ips
  virtual_host_ips          = var.netweaver_virtual_ips
  public_key_location       = var.public_key_location
  private_key_location      = var.private_key_location
  iscsi_srv_ip              = aws_instance.iscsisrv.private_ip
  cluster_ssh_pub           = var.cluster_ssh_pub
  cluster_ssh_key           = var.cluster_ssh_key
  reg_code                  = var.reg_code
  reg_email                 = var.reg_email
  reg_additional_modules    = var.reg_additional_modules
  ha_sap_deployment_repo    = var.ha_sap_deployment_repo
  devel_mode                = var.devel_mode
  provisioner               = var.provisioner
  background                = var.background
  monitoring_enabled        = var.monitoring_enabled
}
