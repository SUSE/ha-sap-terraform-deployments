# Create roles and policies fos SAP clusters

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "cluster-role" {
  count              = var.enabled ? 1 : 0
  name               = "${var.common_variables["deployment_name"]}-${var.name}-cluster"
  description        = "Role used to manage Cluster policies"
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"

  tags = {
    Workspace = var.common_variables["deployment_name"]
  }
}

resource "aws_iam_role_policy" "data-provider-policy" {
  count  = var.enabled ? 1 : 0
  name   = "${var.common_variables["deployment_name"]}-${var.name}-data-provider-policy"
  role   = aws_iam_role.cluster-role[0].id
  policy = templatefile("${path.module}/templates/aws_data_provider_policy.tpl", {})
}

resource "aws_iam_role_policy" "stonith-policy" {
  count  = var.enabled ? 1 : 0
  name   = "${var.common_variables["deployment_name"]}-${var.name}-stonith-policy"
  role   = aws_iam_role.cluster-role[0].id
  policy = templatefile(
    "${path.module}/templates/aws_stonith_policy.tpl",
    {
      region         = var.aws_region
      aws_account_id = data.aws_caller_identity.current.account_id
      ec2_instances  = var.cluster_instances
    }
  )
}

resource "aws_iam_role_policy" "ip-agent-policy" {
  count  = var.enabled ? 1 : 0
  name   = "${var.common_variables["deployment_name"]}-${var.name}-ip-agent-policy"
  role   = aws_iam_role.cluster-role[0].id
  policy = templatefile(
    "${path.module}/templates/aws_ip_agent_policy.tpl",
    {
    region         = var.aws_region
    aws_account_id = data.aws_caller_identity.current.account_id
    route_table    = var.route_table_id
    }
  )
}

resource "aws_iam_instance_profile" "cluster-role-profile" {
  count = var.enabled ? 1 : 0
  name  = "${var.common_variables["deployment_name"]}-${var.name}-role-profile"
  role  = aws_iam_role.cluster-role[0].name
}
