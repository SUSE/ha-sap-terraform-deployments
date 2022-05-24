locals {
  hana_disk_device = "/dev/xvdd"
  create_scale_out = var.hana_count > 1 && var.common_variables["hana"]["scale_out_enabled"] ? 1 : 0
  create_ha_infra  = var.hana_count > 1 && var.common_variables["hana"]["ha_enabled"] ? 1 : 0
  hostname         = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name

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

resource "aws_subnet" "hana-subnet" {
  count             = var.hana_count
  vpc_id            = var.vpc_id
  cidr_block        = element(var.subnet_address_range, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name      = "${var.common_variables["deployment_name"]}-hana-subnet-${count.index + 1}"
    Workspace = var.common_variables["deployment_name"]
  }
}

resource "aws_route_table_association" "hana-subnet-route-association" {
  count          = var.hana_count
  subnet_id      = element(aws_subnet.hana-subnet.*.id, count.index)
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
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.hana-subnet.*.id, count.index)
  private_ip                  = element(var.host_ips, count.index)
  vpc_security_group_ids      = [var.security_group_id]
  availability_zone           = element(var.availability_zones, count.index)
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

module "hana_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.hana_count
  instance_ids = aws_instance.hana.*.id
  user         = "ec2-user"
  private_key  = var.common_variables["private_key"]
  public_ips   = aws_instance.hana.*.public_ip
  dependencies = concat(
    [aws_route_table_association.hana-subnet-route-association],
    var.on_destroy_dependencies
  )
}
