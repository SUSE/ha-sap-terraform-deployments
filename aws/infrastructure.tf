# Configure the AWS Provider
provider "aws" {
  version = "~> 2.7"
  region  = var.aws_region
}

provider "template" {
  version = "~> 2.1"
}

locals {
  infra_subnet_address_range     = var.infra_subnet_address_range != "" ? var.infra_subnet_address_range : cidrsubnet(aws_vpc.vpc.cidr_block, 8, 0)
  hana_subnet_address_range      = length(var.hana_subnet_address_range) != 0 ? var.hana_subnet_address_range : [
    for index in range(var.hana_count): cidrsubnet(aws_vpc.vpc.cidr_block, 8, index + 1)]
  # The 2 is hardcoded because we create 2 subnets for NW always
  netweaver_subnet_address_range = length(var.netweaver_subnet_address_range) != 0 ? var.netweaver_subnet_address_range : [
    for index in range(2): cidrsubnet(aws_vpc.vpc.cidr_block, 8, index + var.hana_count + 1)]
}

# AWS key pair
resource "aws_key_pair" "hana-key-pair" {
  key_name   = "${terraform.workspace} - terraform"
  public_key = file(var.public_key_location)
}

# AWS availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Network resources: VPC, Internet Gateways, Security Groups for the EC2 instances and for the EFS file system
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_address_range
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

resource "aws_subnet" "infra-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.infra_subnet_address_range
  availability_zone = element(data.aws_availability_zones.available.names, 0)

  tags = {
    Name      = "${terraform.workspace}-infra-subnet"
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

resource "aws_route_table_association" "infra-subnet-route-association" {
  subnet_id      = aws_subnet.infra-subnet.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
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
  cidr_blocks = [var.vpc_address_range]

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
  from_port   = 9668
  to_port     = 9668
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
  from_port   = 9664
  to_port     = 9664
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
