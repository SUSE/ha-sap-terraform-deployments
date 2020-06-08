# Network resources: subnets, routes, etc

resource "aws_subnet" "hana-subnet" {
  count             = var.hana_count
  vpc_id            = var.vpc_id
  cidr_block        = element(var.subnet_address_range, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name      = "${terraform.workspace}-hana-subnet-${count.index + 1}"
    Workspace = terraform.workspace
  }
}

resource "aws_route_table_association" "hana-subnet-route-association" {
  count          = var.hana_count
  subnet_id      = element(aws_subnet.hana-subnet.*.id, count.index)
  route_table_id = var.route_table_id
}

resource "aws_route" "hana-cluster-vip" {
  count                  = var.hana_count > 0 ? 1 : 0
  route_table_id         = var.route_table_id
  destination_cidr_block = "${var.hana_cluster_vip}/32"
  instance_id            = aws_instance.clusternodes.0.id
}

module "sap_cluster_policies" {
  enabled           = var.hana_count > 0 ? true : false
  source            = "../../modules/sap_cluster_policies"
  name              = var.name
  aws_region        = var.aws_region
  cluster_instances = aws_instance.clusternodes.*.id
  route_table_id    = var.route_table_id
}

module "get_os_image" {
  source   = "../../modules/get_os_image"
  os_image = var.os_image
  os_owner = var.os_owner
}

## EC2 HANA Instance
resource "aws_instance" "clusternodes" {
  count                       = var.hana_count
  ami                         = module.get_os_image.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.hana-subnet.*.id, count.index)
  private_ip                  = element(var.host_ips, count.index)
  vpc_security_group_ids      = [var.security_group_id]
  availability_zone           = element(var.availability_zones, count.index)
  source_dest_check           = false
  iam_instance_profile        = module.sap_cluster_policies.cluster_profile_name[0]

  root_block_device {
    volume_type = "gp2"
    volume_size = "60"
  }

  ebs_block_device {
    volume_type = var.hana_data_disk_type
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

module "hana_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.hana_count
  instance_ids         = aws_instance.clusternodes.*.id
  user                 = "ec2-user"
  private_key_location = var.private_key_location
  public_ips           = aws_instance.clusternodes.*.public_ip
  dependencies = concat(
    [aws_route_table_association.hana-subnet-route-association],
    var.on_destroy_dependencies
  )
}
