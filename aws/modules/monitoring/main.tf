resource "aws_instance" "monitoring" {
  count                       = var.monitoring_enabled == true ? 1 : 0
  ami                         = var.sles4sap_images[var.aws_region]
  instance_type               = var.monitor_instancetype == "" ? var.min_instancetype : var.monitor_instancetype
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
    Name = "${terraform.workspace}-monitoring"
  }

  tags = {
    Name      = "${terraform.workspace} - Monitoring"
    Workspace = terraform.workspace
  }
}

module "monitoring_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.monitoring_enabled ? 1 : 0
  instance_ids         = aws_instance.monitoring.*.id
  user                 = "ec2-user"
  private_key_location = var.private_key_location
  public_ips           = aws_instance.monitoring.*.public_ip
  dependencies         = var.on_destroy_dependencies
}
