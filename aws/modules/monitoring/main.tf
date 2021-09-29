locals {
  hostname = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

module "get_os_image" {
  source   = "../../modules/get_os_image"
  os_image = var.os_image
  os_owner = var.os_owner
}

resource "aws_instance" "monitoring" {
  count                       = var.monitoring_enabled == true ? 1 : 0
  ami                         = module.get_os_image.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = element(var.subnet_ids, 0)
  private_ip                  = var.monitoring_srv_ip
  vpc_security_group_ids      = [var.security_group_id]
  availability_zone           = element(var.availability_zones, 0)

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  ebs_block_device {
    volume_type = "gp2"
    volume_size = "10"
    device_name = "/dev/xvdd"
  }

  volume_tags = {
    Name = "${var.common_variables["deployment_name"]}-${var.name}"
  }

  tags = {
    Name      = "${var.common_variables["deployment_name"]}-${var.name}"
    Workspace = var.common_variables["deployment_name"]
  }
}

module "monitoring_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.monitoring_enabled ? 1 : 0
  instance_ids = aws_instance.monitoring.*.id
  user         = "ec2-user"
  private_key  = var.common_variables["private_key"]
  public_ips   = aws_instance.monitoring.*.public_ip
  dependencies = var.on_destroy_dependencies
}
