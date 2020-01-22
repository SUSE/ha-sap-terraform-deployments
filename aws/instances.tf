# Launch SLES-HAE of SLES4SAP cluster nodes

# EC2 Instances

resource "aws_instance" "iscsisrv" {
  ami                         = var.iscsi_srv[var.aws_region]
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.mykey.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.local.id
  private_ip                  = "10.0.0.254"
  security_groups             = [aws_security_group.secgroup.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  ebs_block_device {
    volume_type = "gp2"
    volume_size = "10"
    device_name = "/dev/xvdd"
  }

  tags = {
    Name      = "${terraform.workspace} - iSCSI Server"
    Workspace = terraform.workspace
  }
}

resource "aws_instance" "clusternodes" {
  count                       = var.ninstances
  ami                         = var.sles4sap[var.aws_region]
  instance_type               = var.instancetype
  key_name                    = aws_key_pair.mykey.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.local.id
  private_ip                  = element(var.host_ips, count.index)
  security_groups             = [aws_security_group.secgroup.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = "60"
  }

  ebs_block_device {
    volume_type = var.hana_data_disk_type
    volume_size = "60"
    device_name = "/dev/xvdd"
  }

  tags = {
    Name = "${terraform.workspace} - Node-${count.index}"
  }
}


resource "aws_instance" "monitoring" {
  count                       = var.monitoring_enabled == true ? 1 : 0
  ami                         = var.sles4sap[var.aws_region]
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.mykey.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.local.id
  private_ip                  = var.monitoring_srv_ip
  security_groups             = [aws_security_group.secgroup.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  ebs_block_device {
    volume_type = "gp2"
    volume_size = "10"
    device_name = "/dev/xvdd"
  }

  tags = {
    Name = "${terraform.workspace} - Monitoring"
  }
}
