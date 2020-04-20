# iscsi server resources

resource "aws_instance" "iscsisrv" {
  ami                         = var.iscsi_srv_images[var.aws_region]
  instance_type               = var.iscsi_instancetype == "" ? var.min_instancetype : var.iscsi_instancetype
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = element(var.subnet_ids, 0)
  private_ip                  = var.iscsi_srv_ip
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
    Name = "${terraform.workspace}-iscsi"
  }

  tags = {
    Name      = "${terraform.workspace} - iSCSI Server"
    Workspace = terraform.workspace
  }
}

module "iscsi_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = 1
  instance_ids         = aws_instance.iscsisrv.*.id
  user                 = "ec2-user"
  private_key_location = var.private_key_location
  public_ips           = aws_instance.iscsisrv.*.public_ip
  dependencies         = var.on_destroy_dependencies
}
