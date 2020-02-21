# Launch SLES-HAE of SLES4SAP cluster nodes

data "aws_availability_zones" "available" {
  state = "available"
}

# EC2 Instances

resource "aws_instance" "iscsisrv" {
  ami                         = var.iscsi_srv[var.aws_region]
  instance_type               = "t2.micro"
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

module "sap_cluster_policies" {
  source            = "./modules/sap_cluster_policies"
  name              = var.name
  aws_region        = var.aws_region
  aws_account_id    = var.aws_account_id
  cluster_instances = aws_instance.clusternodes.*.id
  route_table_id    = aws_route_table.route-table.id
}

resource "aws_instance" "clusternodes" {
  count                       = var.ninstances
  ami                         = var.sles4sap[var.aws_region]
  instance_type               = var.instancetype
  key_name                    = aws_key_pair.hana-key-pair.key_name
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.hana-subnet.*.id, count.index)
  private_ip                  = element(var.host_ips, count.index)
  security_groups             = [aws_security_group.secgroup.id]
  availability_zone           = element(data.aws_availability_zones.available.names, count.index)
  source_dest_check           = false
  iam_instance_profile        = module.sap_cluster_policies.cluster_profile_name

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
    Name = "${terraform.workspace}-${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}"
  }

  tags = {
    Name      = "${terraform.workspace} - ${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}"
    Workspace = terraform.workspace
    Cluster   = "${terraform.workspace}-${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}"
  }
}


resource "aws_instance" "monitoring" {
  count                       = var.monitoring_enabled == true ? 1 : 0
  ami                         = var.sles4sap[var.aws_region]
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.hana-key-pair.key_name
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.hana-subnet.*.id, 0)
  private_ip                  = var.monitoring_srv_ip
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
    Name = "${terraform.workspace}-monitoring"
  }

  tags = {
    Name      = "${terraform.workspace} - Monitoring"
    Workspace = terraform.workspace
  }
}
