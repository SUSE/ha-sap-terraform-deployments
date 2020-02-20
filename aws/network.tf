# Launch SLES-HAE of SLES4SAP cluster nodes

# Network resources: VPC, Internet Gateways, Security Groups for the EC2 instances and for the EFS file system
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${terraform.workspace}-vpc"
    Workspace = terraform.workspace
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "${terraform.workspace}-igw"
    Workspace = terraform.workspace
  }
}

resource "aws_subnet" "hana-subnet" {
  count             = var.ninstances
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name      = "${terraform.workspace}-hana-subnet-${count.index + 1}"
    Workspace = terraform.workspace
  }
}

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "${terraform.workspace}-hana-route-table"
    Workspace = terraform.workspace
  }
}

resource "aws_route_table_association" "hana-subnet-route-association" {
  count          = var.ninstances
  subnet_id      = element(aws_subnet.hana-subnet.*.id, count.index)
  route_table_id = aws_route_table.route-table.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "hana-cluster-vip" {
  route_table_id         = aws_route_table.route-table.id
  destination_cidr_block = "${var.hana_cluster_vip}/32"
  instance_id            = aws_instance.clusternodes.0.id
}


resource "aws_security_group" "secgroup" {
  name   = "${terraform.workspace}-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "${terraform.workspace}-sg"
    Workspace = terraform.workspace
  }
}

resource "aws_security_group_rule" "outall" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.secgroup.id
}

resource "aws_security_group_rule" "local" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["10.0.0.0/16"]

  security_group_id = aws_security_group.secgroup.id
}

resource "aws_security_group_rule" "http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.secgroup.id
}

resource "aws_security_group_rule" "https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.secgroup.id
}

resource "aws_security_group_rule" "hawk" {
  type        = "ingress"
  from_port   = 7630
  to_port     = 7630
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.secgroup.id
}

resource "aws_security_group_rule" "ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.secgroup.id
}


# Monitoring rules
resource "aws_security_group_rule" "hanadb_exporter" {
  count       = var.monitoring_enabled == true ? 1 : 0
  type        = "ingress"
  from_port   = 8001
  to_port     = 8001
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.secgroup.id
}


resource "aws_security_group_rule" "node_exporter" {
  count       = var.monitoring_enabled == true ? 1 : 0
  type        = "ingress"
  from_port   = 9100
  to_port     = 9100
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.secgroup.id
}

resource "aws_security_group_rule" "ha_exporter" {
  count       = var.monitoring_enabled == true ? 1 : 0
  type        = "ingress"
  from_port   = 9002
  to_port     = 9002
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.secgroup.id
}

resource "aws_security_group_rule" "prometheus_server" {
  count       = var.monitoring_enabled == true ? 1 : 0
  type        = "ingress"
  from_port   = 9090
  to_port     = 9090
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.secgroup.id
}
