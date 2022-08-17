# iscsi server resources

locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = local.bastion_enabled ? aws_instance.iscsisrv.*.private_ip : aws_instance.iscsisrv.*.public_ip
  hostname = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

module "get_os_image" {
  source   = "../../modules/get_os_image"
  os_image = var.os_image
  os_owner = var.os_owner
}

resource "aws_instance" "iscsisrv" {
  count                       = var.iscsi_count
  ami                         = module.get_os_image.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = local.bastion_enabled ? false : true
  subnet_id                   = element(var.subnet_ids, count.index)
  private_ip                  = element(var.host_ips, count.index)
  vpc_security_group_ids      = [var.security_group_id]
  availability_zone           = element(var.availability_zones, count.index)

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  ebs_block_device {
    volume_type = "gp2"
    volume_size = var.iscsi_disk_size
    device_name = "/dev/sdb"
  }

  volume_tags = {
    Name = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  }

  tags = {
    Name      = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
    Workspace = var.common_variables["deployment_name"]
  }
}

module "iscsi_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.iscsi_count
  instance_ids = aws_instance.iscsisrv.*.id
  user         = var.common_variables["authorized_user"]
  private_key  = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips   = local.provisioning_addresses
  dependencies = var.on_destroy_dependencies
}
