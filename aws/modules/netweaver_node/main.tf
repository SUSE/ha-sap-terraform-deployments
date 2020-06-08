# Network resources: subnets, routes, etc
resource "aws_subnet" "netweaver-subnet" {
  count             = min(var.netweaver_count, 2) # Create 2 subnets max
  vpc_id            = var.vpc_id
  cidr_block        = element(var.subnet_address_range, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name      = "${terraform.workspace}-netweaver-subnet-${count.index + 1}"
    Workspace = terraform.workspace
  }
}

resource "aws_route_table_association" "netweaver-subnet-route-association" {
  count          = min(var.netweaver_count, 2)
  subnet_id      = element(aws_subnet.netweaver-subnet.*.id, count.index)
  route_table_id = var.route_table_id
}

resource "aws_route" "ascs-cluster-vip" {
  count                  = var.netweaver_count > 0 ? 1 : 0
  route_table_id         = var.route_table_id
  destination_cidr_block = "${element(var.virtual_host_ips, 0)}/32"
  instance_id            = aws_instance.netweaver.0.id
}

resource "aws_route" "ers-cluster-vip" {
  count                  = var.netweaver_count > 0 ? 1 : 0
  route_table_id         = var.route_table_id
  destination_cidr_block = "${element(var.virtual_host_ips, 1)}/32"
  instance_id            = aws_instance.netweaver.1.id
}

resource "aws_efs_mount_target" "netweaver-efs-mount-target" {
  count           = var.netweaver_count > 0 && var.efs_enable_mount ? 2 : 0
  file_system_id  = var.efs_file_system_id
  subnet_id       = element(aws_subnet.netweaver-subnet.*.id, count.index)
  security_groups = [var.security_group_id]
}

module "sap_cluster_policies" {
  enabled           = var.netweaver_count > 0 ? true : false
  source            = "../../modules/sap_cluster_policies"
  name              = var.name
  aws_region        = var.aws_region
  cluster_instances = slice(aws_instance.netweaver.*.id, 0, min(var.netweaver_count, 2))
  route_table_id    = var.route_table_id
}

module "get_os_image" {
  source   = "../../modules/get_os_image"
  os_image = var.os_image
  os_owner = var.os_owner
}

resource "aws_instance" "netweaver" {
  count                       = var.netweaver_count
  ami                         = module.get_os_image.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.netweaver-subnet.*.id, count.index % 2) # %2 is used because there are not more than 2 subnets
  private_ip                  = element(var.host_ips, count.index)
  vpc_security_group_ids      = [var.security_group_id]
  availability_zone           = element(var.availability_zones, count.index % 2)
  source_dest_check           = false
  iam_instance_profile        = module.sap_cluster_policies.cluster_profile_name[0] # We apply to all nodes to have the SAP data provider, even though some policies are only for the clustered nodes

  root_block_device {
    volume_type = "gp2"
    volume_size = "60"
  }

  # Disk to store Netweaver software installation files
  ebs_block_device {
    volume_type = "gp2"
    volume_size = "60"
    device_name = "/dev/xvdd"
  }

  volume_tags = {
    Name = "${terraform.workspace}-${var.name}0${count.index + 1}"
  }

  tags = {
    Name                             = "${terraform.workspace} - ${var.name}0${count.index + 1}"
    Workspace                        = terraform.workspace
    "${terraform.workspace}-cluster" = "${var.name}0${count.index + 1}"
  }
}

module "netweaver_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.netweaver_count
  instance_ids         = aws_instance.netweaver.*.id
  user                 = "ec2-user"
  private_key_location = var.private_key_location
  public_ips           = aws_instance.netweaver.*.public_ip
  dependencies = concat(
    [aws_route_table_association.netweaver-subnet-route-association],
    var.on_destroy_dependencies
  )
}
