# Network resources: subnets, routes, etc
resource "aws_subnet" "netweaver-subnet" {
  count              = var.netweaver_count > 2 ? 2 : var.netweaver_count # Create 2 subnets max
  vpc_id             = var.vpc_id
  cidr_block         = cidrsubnet(var.vpc_cidr_block, 8, count.index+2) # +2 is done to don't conflict with hana subnets addresses
  availability_zone  = element(var.availability_zones, count.index)
  tags = {
    Name      = "${terraform.workspace}-netweaver-subnet-${count.index + 1}"
    Workspace = terraform.workspace
  }
}

resource "aws_route_table_association" "netweaver-subnet-route-association" {
  count          = var.netweaver_count > 2 ? 2 : var.netweaver_count
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

# EFS storage for /usr/sap/{sid} and /sapmnt
resource "aws_efs_file_system" "netweaver-efs" {
  count            = var.netweaver_count > 0 ? 1 : 0
  creation_token   = "${terraform.workspace}-netweaver-efs"
  performance_mode = "generalPurpose"

  tags = {
    Name = "${terraform.workspace}-efs"
  }
}

resource "aws_efs_mount_target" "netweaver-efs-mount-target" {
  count           = var.netweaver_count > 2 ? 2 : var.netweaver_count
  file_system_id  = element(aws_efs_file_system.netweaver-efs.*.id, 0)
  subnet_id       = element(aws_subnet.netweaver-subnet.*.id, count.index)
  security_groups = [var.security_group_id]
}

module "sap_cluster_policies" {
  source             = "../../modules/sap_cluster_policies"
  name               = var.name
  aws_region         = var.aws_region
  aws_account_id     = var.aws_account_id
  cluster_instances  = aws_instance.netweaver.*.id
  route_table_id     = var.route_table_id
}

resource "aws_instance" "netweaver" {
  count                       = var.netweaver_count
  ami                         = var.sles4sap_images[var.aws_region]
  instance_type               = var.instancetype
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.netweaver-subnet.*.id, count.index%2) # %2 is used because there are not more than 2 subnets
  private_ip                  = element(var.host_ips, count.index)
  security_groups             = [var.security_group_id]
  availability_zone           = element(var.availability_zones, count.index%2)
  source_dest_check           = false
  iam_instance_profile        = module.sap_cluster_policies.cluster_profile_name # We apply to all nodes to have the SAP data provider, even though some policies are only for the clustered nodes

  root_block_device {
    volume_type = "gp2"
    volume_size = "60"
  }

  volume_tags = {
    Name = "${terraform.workspace}-${var.name}${var.netweaver_count > 1 ? "0${count.index + 1}" : ""}"
  }

  tags = {
    Name         = "${terraform.workspace} - ${var.name}${var.netweaver_count > 1 ? "0${count.index + 1}" : ""}"
    Workspace    = terraform.workspace
    Cluster      = "${var.name}${var.netweaver_count > 1 ? "0${count.index + 1}" : ""}"
  }
}
