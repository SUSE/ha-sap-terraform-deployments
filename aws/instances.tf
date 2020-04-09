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

module "sap_cluster_policies" {
  enabled           = var.ninstances > 0 ? true : false
  source            = "./modules/sap_cluster_policies"
  name              = var.name
  aws_region        = var.aws_region
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
  iam_instance_profile        = module.sap_cluster_policies.cluster_profile_name[0]

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

module "hana_on_destroy" {
  source               = "../generic_modules/on_destroy"
  node_count           = var.ninstances
  instance_ids         = aws_instance.clusternodes.*.id
  user                 = "ec2-user"
  private_key_location = var.private_key_location
  public_ips           = aws_instance.clusternodes.*.public_ip
  dependencies = [
    aws_route_table_association.hana-subnet-route-association,
    aws_route.public,
    aws_security_group_rule.ssh,
    aws_security_group_rule.outall
  ]
}

