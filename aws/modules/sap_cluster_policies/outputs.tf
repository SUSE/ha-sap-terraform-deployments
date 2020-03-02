output "cluster_profile_name" {
  value = aws_iam_instance_profile.cluster-role-profile.*.name
}
