# Launch SLES-HAE of SLES4SAP cluster nodes

data "aws_availability_zones" "available" {
  state = "available"
}

# EC2 Instances

resource "aws_instance" "iscsisrv" {
  ami                         = var.iscsi_srv[var.aws_region]
  instance_type               = var.iscsi_instancetype == "" ? var.min_instancetype : var.iscsi_instancetype
  key_name                    = aws_key_pair.hana-key-pair.key_name
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.hana-subnet.*.id, 0)
  private_ip                  = "10.0.0.254"
  security_groups             = [aws_security_group.secgroup.id]
  availability_zone           = element(data.aws_availability_zones.available.names, 0)

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
  source               = "../generic_modules/on_destroy"
  node_count           = 1
  instance_ids         = aws_instance.iscsisrv.*.id
  user                 = "ec2-user"
  private_key_location = var.private_key_location
  public_ips           = aws_instance.iscsisrv.*.public_ip
  dependencies = [
    aws_route_table_association.hana-subnet-route-association,
    aws_route.public,
    aws_security_group_rule.ssh,
    aws_security_group_rule.outall
  ]
}
