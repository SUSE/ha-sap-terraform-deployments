data "aws_vpc" "current-vpc" {
  count = var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

data "aws_internet_gateway" "current-gateway" {
  count = var.vpc_id != "" ? 1 : 0
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

locals {
  deployment_name = var.deployment_name != "" ? var.deployment_name : terraform.workspace

  vpc_id            = var.vpc_id == "" ? aws_vpc.vpc.0.id : var.vpc_id
  internet_gateway  = var.vpc_id == "" ? aws_internet_gateway.igw.0.id : data.aws_internet_gateway.current-gateway.0.internet_gateway_id
  security_group_id = var.security_group_id != "" ? var.security_group_id : aws_security_group.secgroup.0.id
  vpc_address_range = var.vpc_id == "" ? var.vpc_address_range : (var.vpc_address_range == "" ? data.aws_vpc.current-vpc.0.cidr_block : var.vpc_address_range)

  public_subnet_address_range = var.public_subnet_address_range != "" ? var.public_subnet_address_range : cidrsubnet(local.vpc_address_range, 8, 254)
  infra_subnet_address_range = var.infra_subnet_address_range != "" ? var.infra_subnet_address_range : cidrsubnet(local.vpc_address_range, 8, 0)

  # The +1 is added in case we have a HANA scale-out setup
  hana_subnet_address_range = length(var.hana_subnet_address_range) != 0 ? var.hana_subnet_address_range : [
  for index in range(var.hana_count + local.create_scale_out) : cidrsubnet(local.vpc_address_range, 8, index + 1)]

  # The 2 is hardcoded because we create 2 subnets for NW always
  # The +1 is added in case we have a HANA scale-out setup
  netweaver_subnet_address_range = length(var.netweaver_subnet_address_range) != 0 ? var.netweaver_subnet_address_range : [
  for index in range(2) : cidrsubnet(local.vpc_address_range, 8, index + var.hana_count + 1 + local.create_scale_out)]

  # The 2 is hardcoded considering we create 2 subnets for NW always
  drbd_subnet_address_range = length(var.drbd_subnet_address_range) != 0 ? var.drbd_subnet_address_range : [
  for index in range(2) : cidrsubnet(local.vpc_address_range, 8, index + var.hana_count + 2 + 1 + local.create_scale_out)]
}

# AWS key pair
resource "aws_key_pair" "key-pair" {
  key_name   = "${local.deployment_name} - terraform"
  public_key = module.common_variables.configuration["public_key"]
}

# AWS availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Network resources: VPC, Internet Gateways, Security Groups for the EC2 instances and for the EFS file system
resource "aws_vpc" "vpc" {
  count                = var.vpc_id == "" ? 1 : 0
  cidr_block           = local.vpc_address_range
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${local.deployment_name}-vpc"
    Workspace = local.deployment_name
  }
}

resource "aws_internet_gateway" "igw" {
  count  = var.vpc_id == "" ? 1 : 0
  vpc_id = local.vpc_id

  tags = {
    Name      = "${local.deployment_name}-igw"
    Workspace = local.deployment_name
  }
}

resource "aws_subnet" "infra" {
  vpc_id            = local.vpc_id
  cidr_block        = local.infra_subnet_address_range
  availability_zone = element(data.aws_availability_zones.available.names, 0)

  tags = {
    Name      = "${local.deployment_name}-infra-subnet"
    Workspace = local.deployment_name
  }
}

resource "aws_route_table" "private" {
  count   = var.bastion_enabled ? 1 : 0
  vpc_id = local.vpc_id

  tags = {
    Name      = "${local.deployment_name}-route-table-private"
    Workspace = local.deployment_name
  }

  depends_on = [aws_nat_gateway.ngw]
}

resource "aws_route" "private" {
  count   = var.bastion_enabled ? 1 : 0
  route_table_id         = aws_route_table.private.0.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = aws_nat_gateway.ngw.0.id
}

resource "aws_route_table_association" "infra" {
  subnet_id      = aws_subnet.infra.id
  route_table_id = var.bastion_enabled ? aws_route_table.private.0.id : aws_route_table.public.id
}

# Network resources: NAT Gateway, subnets and routes when deploying the bastion host setup
resource "aws_eip" "ngw" {
  count       = var.bastion_enabled ? 1 : 0
  vpc      = true

  tags = {
    Name      = "${local.deployment_name}-eip-ngw"
    Workspace = local.deployment_name
  }

  depends_on = [local.internet_gateway]
}

resource "aws_nat_gateway" "ngw" {
  count  = var.vpc_id == "" && var.bastion_enabled ? 1 : 0
  connectivity_type = "public"
  allocation_id = aws_eip.ngw.0.id
  subnet_id = aws_subnet.public.id

  tags = {
    Name      = "${local.deployment_name}-ngw"
    Workspace = local.deployment_name
  }
}

resource "aws_subnet" "public" {
  vpc_id            = local.vpc_id
  cidr_block        = local.public_subnet_address_range
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  map_public_ip_on_launch = true

  tags = {
    Name      = "${local.deployment_name}-public-subnet"
    Workspace = local.deployment_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = local.vpc_id

  tags = {
    Name      = "${local.deployment_name}-route-table-public"
    Workspace = local.deployment_name
  }

  depends_on = [aws_nat_gateway.ngw]
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = local.internet_gateway
}

locals {
  create_security_group            = var.security_group_id == "" ? 1 : 0
  create_security_group_monitoring = var.security_group_id == "" && var.monitoring_enabled == true ? 1 : 0
}

resource "aws_security_group" "secgroup" {
  count  = local.create_security_group
  name   = "${local.deployment_name}-sg"
  vpc_id = local.vpc_id

  tags = {
    Name      = "${local.deployment_name}-sg"
    Workspace = local.deployment_name
  }
}

resource "aws_security_group_rule" "outall" {
  count       = local.create_security_group
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = local.security_group_id
}

resource "aws_security_group_rule" "local" {
  count       = local.create_security_group
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [local.vpc_address_range]

  security_group_id = local.security_group_id
}

resource "aws_security_group_rule" "hawk" {
  count       = var.bastion_enabled ? 0 : local.create_security_group
  type        = "ingress"
  from_port   = 7630
  to_port     = 7630
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = local.security_group_id
}

resource "aws_security_group_rule" "ssh" {
  count       = local.create_security_group
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = local.security_group_id
}


# Monitoring rules
resource "aws_security_group_rule" "http" {
  count       = local.create_security_group_monitoring
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = local.security_group_id
}

resource "aws_security_group_rule" "https" {
  count       = local.create_security_group_monitoring
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = local.security_group_id
}

#resource "aws_security_group_rule" "hanadb_exporter" {
#  count       = local.create_security_group_monitoring
#  type        = "ingress"
#  from_port   = 9668
#  to_port     = 9668
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#
#  security_group_id = local.security_group_id
#}
#
#
#resource "aws_security_group_rule" "node_exporter" {
#  count       = local.create_security_group_monitoring
#  type        = "ingress"
#  from_port   = 9100
#  to_port     = 9100
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#
#  security_group_id = local.security_group_id
#}
#
#resource "aws_security_group_rule" "ha_exporter" {
#  count       = local.create_security_group_monitoring
#  type        = "ingress"
#  from_port   = 9664
#  to_port     = 9664
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#
#  security_group_id = local.security_group_id
#}
#
#resource "aws_security_group_rule" "saphost_exporter" {
#  count       = local.create_security_group_monitoring
#  type        = "ingress"
#  from_port   = 9680
#  to_port     = 9680
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#
#  security_group_id = local.security_group_id
#}

#resource "aws_security_group_rule" "prometheus_server" {
#  count       = local.create_security_group_monitoring
#  type        = "ingress"
#  from_port   = 9090
#  to_port     = 9090
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#
#  security_group_id = local.security_group_id
#}

resource "aws_security_group_rule" "grafana_server" {
  count       = local.create_security_group_monitoring
  type        = "ingress"
  from_port   = 3000
  to_port     = 3000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = local.security_group_id
}

# Bastion
module "bastion" {
  source             = "./modules/bastion"
  common_variables   = module.common_variables.configuration
  name               = var.bastion_name
  network_domain     = var.bastion_network_domain == "" ? var.network_domain : var.bastion_network_domain
  bastion_count      = module.common_variables.configuration["bastion_enabled"] ? 1 : 0
  aws_region         = var.aws_region
  availability_zones = data.aws_availability_zones.available.names
  subnet_ids         = var.bastion_enabled ? [aws_subnet.public.id] : []
  os_image           = local.bastion_os_image
  os_owner           = local.bastion_os_owner
  instance_type      = var.bastion_instancetype
  key_name           = aws_key_pair.key-pair.key_name
  security_group_id = local.security_group_id
  host_ips           = [local.bastion_ip]
  on_destroy_dependencies = [
    aws_route_table_association.public,
    aws_route.public,
    aws_security_group_rule.ssh,
    aws_security_group_rule.outall
  ]
}
