# Launch SLES-HAE of SLES4SAP cluster nodes

# Network resources: VPC, Internet Gateways, Security Groups for the EC2 instances and for the EFS file system
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Workspace = "${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Network   = "Public"
    Workspace = "${terraform.workspace}"
  }
}

resource "aws_route_table" "routetable" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Workspace = "${terraform.workspace}"
  }
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.routetable.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.local.id}"
  route_table_id = "${aws_route_table.routetable.id}"
}

resource "aws_subnet" "local" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${aws_vpc.vpc.cidr_block}"

  tags {
    Workspace = "${terraform.workspace}"
  }
}

resource "aws_security_group" "secgroup" {
  name   = "secgroup"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Workspace = "${terraform.workspace}"
  }
}

resource "aws_security_group_rule" "outall" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.secgroup.id}"
}

resource "aws_security_group_rule" "local" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["10.0.0.0/16"]

  security_group_id = "${aws_security_group.secgroup.id}"
}

resource "aws_security_group_rule" "http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.secgroup.id}"
}

resource "aws_security_group_rule" "https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.secgroup.id}"
}

resource "aws_security_group_rule" "hawk" {
  type        = "ingress"
  from_port   = 7630
  to_port     = 7630
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.secgroup.id}"
}

resource "aws_security_group_rule" "ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.secgroup.id}"
}
