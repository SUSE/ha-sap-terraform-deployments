locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = local.bastion_enabled ? aws_instance.majority_maker.*.private_ip : aws_instance.majority_maker.*.public_ip
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

# Network resources: subnets, routes, etc

resource "aws_subnet" "majority_maker-subnet" {
  count             = var.node_count
  vpc_id            = var.vpc_id
  cidr_block        = element(var.subnet_address_range, 2) # hardcode 3rd subnet
  availability_zone = element(var.availability_zones, 2)   # hardcode 3rd az

  tags = {
    Name      = "${var.common_variables["deployment_name"]}-hana-subnet-3"
    Workspace = var.common_variables["deployment_name"]
  }
}

resource "aws_route_table_association" "majority_maker-subnet-route-association" {
  count          = var.node_count
  subnet_id      = element(aws_subnet.majority_maker-subnet.*.id, count.index)
  route_table_id = var.route_table_id
}

module "get_os_image" {
  source   = "../../modules/get_os_image"
  os_image = var.os_image
  os_owner = var.os_owner
}

## EC2 HANA Instance
resource "aws_instance" "majority_maker" {
  count                       = var.node_count
  ami                         = module.get_os_image.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = local.bastion_enabled ? false : true
  subnet_id                   = element(aws_subnet.majority_maker-subnet.*.id, count.index)
  private_ip                  = var.majority_maker_ip
  vpc_security_group_ids      = [var.security_group_id]
  availability_zone           = element(var.availability_zones, 2) # hardcode 3rd az
  iam_instance_profile        = "${var.common_variables["deployment_name"]}-${var.name}-role-profile"
  source_dest_check           = false

  root_block_device {
    volume_type = "gp2"
    volume_size = "60"
  }

  volume_tags = {
    Name = "${var.common_variables["deployment_name"]}-${var.name}mm"
  }

  tags = {
    Name                                                 = "${var.common_variables["deployment_name"]}-${var.name}mm"
    Workspace                                            = var.common_variables["deployment_name"]
    "${var.common_variables["deployment_name"]}-cluster" = "${var.name}mm"
  }
}

module "majority_maker_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.node_count
  instance_ids        = aws_instance.majority_maker.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  dependencies = concat(
    [aws_route_table_association.majority_maker-subnet-route-association],
    var.on_destroy_dependencies
  )
}
