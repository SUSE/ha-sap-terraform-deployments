{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1424860166260",
            "Action": [
                "ec2:DescribeRouteTables",
                "ec2:ReplaceRoute"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:ec2:${region}:${aws_account_id}:route-table/${route_table}"
        }
    ]
}
