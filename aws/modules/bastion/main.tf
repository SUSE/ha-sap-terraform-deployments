# bastion server resources

locals {
  provisioning_addresses = aws_instance.bastion.*.public_ip
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

# AWS key pair
resource "aws_key_pair" "key-pair" {
  count      = var.bastion_count
  key_name   = "${var.common_variables["deployment_name"]} - terraform-bastion"
  public_key = var.common_variables["bastion_public_key"]
}

module "get_os_image" {
  source   = "../../modules/get_os_image"
  os_image = var.os_image
  os_owner = var.os_owner
}

resource "aws_instance" "bastion" {
  count                       = var.bastion_count
  ami                         = module.get_os_image.image_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key-pair.0.key_name
  associate_public_ip_address = true
  subnet_id                   = element(var.subnet_ids, count.index)
  private_ip                  = element(var.host_ips, count.index)
  vpc_security_group_ids      = [var.security_group_id]
  availability_zone           = element(var.availability_zones, count.index)

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  volume_tags = {
    Name = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  }

  tags = {
    Name      = "${var.common_variables["deployment_name"]}-${var.name}"
    Workspace = var.common_variables["deployment_name"]
  }
}

module "bastion_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.bastion_count
  instance_ids = aws_instance.bastion.*.id
  user         = var.common_variables["authorized_user"]
  private_key  = var.common_variables["bastion_private_key"]
  public_ips   = local.provisioning_addresses
  dependencies = var.on_destroy_dependencies
}
