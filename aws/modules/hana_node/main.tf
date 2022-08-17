locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = local.bastion_enabled ? aws_instance.hana.*.private_ip : aws_instance.hana.*.public_ip
  create_scale_out   = var.hana_count > 1 && var.common_variables["hana"]["scale_out_enabled"] ? 1 : 0
  create_ha_infra    = var.hana_count > 1 && var.common_variables["hana"]["ha_enabled"] ? 1 : 0
  hostname           = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
  shared_storage_efs = var.common_variables["hana"]["scale_out_shared_storage_type"] == "efs" ? 1 : 0
  sites              = local.create_ha_infra == 1 ? 2 : 1

  disks_number = length(split(",", var.hana_data_disks_configuration["disks_size"]))
  disks_size   = [for disk_size in split(",", var.hana_data_disks_configuration["disks_size"]) : tonumber(trimspace(disk_size))]
  disks_type   = [for disk_type in split(",", var.hana_data_disks_configuration["disks_type"]) : trimspace(disk_type)]
  disks_name   = [for disk_name in split(",", var.block_devices) : trimspace(disk_name)]
  disks = flatten([
    for node in range(var.hana_count) : [
      for disk in range(local.disks_number) : {
        node_num    = node
        node        = "${local.hostname}${format("%02d", node + 1)}"
        disk_number = disk
        disk_name   = element(local.disks_name, disk)
        disk_size   = element(local.disks_size, disk)
        disk_type   = element(local.disks_type, disk)
      }
    ]
  ])
}

# Network resources: subnets, routes, etc

resource "aws_subnet" "hana" {
  count             = local.sites
  vpc_id            = var.vpc_id
  cidr_block        = element(var.subnet_address_range, count.index)
  availability_zone = element(var.availability_zones, count.index % 2)

  tags = {
    Name      = "${var.common_variables["deployment_name"]}-hana-subnet-${count.index + 1}"
    Workspace = var.common_variables["deployment_name"]
  }
}

resource "aws_route_table_association" "hana" {
  count          = local.sites
  subnet_id      = element(aws_subnet.hana.*.id, count.index)
  route_table_id = var.route_table_id
}

resource "aws_route" "hana-cluster-vip" {
  count                  = local.create_ha_infra
  route_table_id         = var.route_table_id
  destination_cidr_block = "${var.common_variables["hana"]["cluster_vip"]}/32"
  network_interface_id   = aws_instance.hana.0.primary_network_interface_id
}

resource "aws_route" "hana-cluster-vip-secondary" {
  count                  = local.create_ha_infra == 1 && var.common_variables["hana"]["cluster_vip_secondary"] != "" ? 1 : 0
  route_table_id         = var.route_table_id
  destination_cidr_block = "${var.common_variables["hana"]["cluster_vip_secondary"]}/32"
  network_interface_id   = aws_instance.hana.1.primary_network_interface_id
}

# EFS storage for nfs share used by HANA scale-out for /hana/shared
resource "aws_efs_file_system" "scale-out-efs-shared" {
  count            = local.create_scale_out == 1 && local.shared_storage_efs == 1 ? local.sites : 0
  creation_token   = "${var.common_variables["deployment_name"]}-hana-efs-${count.index + 1}"
  performance_mode = var.efs_performance_mode

  tags = {
    Name = "${var.common_variables["deployment_name"]}-hana-efs-${count.index + 1}"
  }
}

resource "aws_efs_mount_target" "scale-out-efs-mount-target" {
  count           = local.create_scale_out == 1 && local.shared_storage_efs == 1 ? local.sites : 0
  file_system_id  = aws_efs_file_system.scale-out-efs-shared[count.index].id
  subnet_id       = element(aws_subnet.hana.*.id, count.index)
  security_groups = [var.security_group_id]
}

module "sap_cluster_policies" {
  enabled           = var.hana_count > 0 ? true : false
  source            = "../../modules/sap_cluster_policies"
  common_variables  = var.common_variables
  name              = var.name
  aws_region        = var.aws_region
  cluster_instances = aws_instance.hana.*.id
  route_table_id    = var.route_table_id
}

module "get_os_image" {
  source   = "../../modules/get_os_image"
  os_image = var.os_image
  os_owner = var.os_owner
}

## EC2 HANA Instance
resource "aws_instance" "hana" {
  count                       = var.hana_count
  ami                         = module.get_os_image.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = local.bastion_enabled ? false : true
  subnet_id                   = element(aws_subnet.hana.*.id, count.index % 2)
  private_ip                  = element(var.host_ips, count.index)
  vpc_security_group_ids      = [var.security_group_id]
  availability_zone           = element(var.availability_zones, count.index % 2)
  iam_instance_profile        = module.sap_cluster_policies.cluster_profile_name[0]
  source_dest_check           = false

  root_block_device {
    volume_type = "gp2"
    volume_size = "60"
  }

  dynamic "ebs_block_device" {
    for_each = { for disk in local.disks : "${disk.disk_name}" => disk if disk.node_num == count.index }
    content {
      volume_type = ebs_block_device.value.disk_type
      volume_size = ebs_block_device.value.disk_size
      device_name = ebs_block_device.value.disk_name
    }
  }

  volume_tags = {
    Name = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  }

  tags = {
    Name                                                 = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
    Workspace                                            = var.common_variables["deployment_name"]
    "${var.common_variables["deployment_name"]}-cluster" = "${var.name}${format("%02d", count.index + 1)}"
  }
}

module "hana_majority_maker" {
  source                = "../majority_maker_node"
  common_variables      = var.common_variables
  node_count            = local.create_scale_out
  name                  = var.name
  network_domain        = var.network_domain
  hana_count            = var.hana_count
  instance_type         = var.majority_maker_instancetype
  aws_region            = var.aws_region
  availability_zones    = var.availability_zones
  os_image              = var.os_image
  os_owner              = var.os_owner
  vpc_id                = var.vpc_id
  subnet_address_range  = var.subnet_address_range
  key_name              = var.key_name
  security_group_id     = var.security_group_id
  route_table_id        = var.route_table_id
  efs_performance_mode  = var.efs_performance_mode
  aws_credentials       = var.aws_credentials
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  host_ips              = var.host_ips
  majority_maker_ip     = var.majority_maker_ip
  iscsi_srv_ip          = var.iscsi_srv_ip
  cluster_ssh_pub       = var.cluster_ssh_pub
  cluster_ssh_key       = var.cluster_ssh_key
}

module "hana_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.hana_count
  instance_ids = aws_instance.hana.*.id
  user         = "ec2-user"
  private_key  = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips   = aws_instance.hana.*.public_ip
  dependencies = concat(
    [aws_route_table_association.hana],
    var.on_destroy_dependencies
  )
}
