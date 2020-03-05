# Create roles and policies fos SAP clusters
resource "aws_iam_role" "cluster-role" {
  count              = var.enabled ? 1 : 0
  name               = "${terraform.workspace}-${var.name}-cluster"
  description        = "Role used to manage Cluster policies"
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"

  tags = {
    Workspace = terraform.workspace
  }
}

data "template_file" "data-provider-policy-template" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/templates/aws_data_provider_policy.tpl")
}

resource "aws_iam_role_policy" "data-provider-policy" {
  count  = var.enabled ? 1 : 0
  name   = "${terraform.workspace}-${var.name}-data-provider-policy"
  role   = aws_iam_role.cluster-role[0].id
  policy = data.template_file.data-provider-policy-template[0].rendered
}

data "template_file" "stonith-policy-template" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/templates/aws_stonith_policy.tpl")
  vars = {
    region         = var.aws_region
    aws_account_id = var.aws_account_id
    ec2_instance1  = var.cluster_instances.0
    ec2_instance2  = var.cluster_instances.1
  }
}

resource "aws_iam_role_policy" "stonith-policy" {
  count  = var.enabled ? 1 : 0
  name   = "${terraform.workspace}-${var.name}-stonith-policy"
  role   = aws_iam_role.cluster-role[0].id
  policy = data.template_file.stonith-policy-template[0].rendered
}

data "template_file" "ip-agent-policy-template" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/templates/aws_ip_agent_policy.tpl")
  vars = {
    region         = var.aws_region
    aws_account_id = var.aws_account_id
    route_table    = var.route_table_id
  }
}

resource "aws_iam_role_policy" "ip-agent-policy" {
  count  = var.enabled ? 1 : 0
  name   = "${terraform.workspace}-${var.name}-ip-agent-policy"
  role   = aws_iam_role.cluster-role[0].id
  policy = data.template_file.ip-agent-policy-template[0].rendered
}

resource "aws_iam_instance_profile" "cluster-role-profile" {
  count = var.enabled ? 1 : 0
  name  = "${terraform.workspace}-${var.name}-role-profile"
  role  = aws_iam_role.cluster-role[0].name
}
