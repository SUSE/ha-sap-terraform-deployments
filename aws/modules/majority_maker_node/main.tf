locals {
  hostname = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
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
  associate_public_ip_address = true
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
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.node_count
  instance_ids = aws_instance.majority_maker.*.id
  user         = "ec2-user"
  private_key  = var.common_variables["private_key"]
  public_ips   = aws_instance.majority_maker.*.public_ip
  dependencies = concat(
    [aws_route_table_association.majority_maker-subnet-route-association],
    var.on_destroy_dependencies
  )
}
