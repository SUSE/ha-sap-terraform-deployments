## Overview

### Store State Remotely in S3

If you are working on a team, then its best to store the Terraform state file remotely so that many people can access it. In order to setup terraform to store state remotely you need two things: a S3 bucket to store the state file in and a Terraform S3 backend resource.

### What is locking and why do we need it?

If the state file is stored remotely so that many people can access it, then you risk multiple people attempting to make changes to the same file at the exact same time. So we need to provide a mechanism that will “lock” the state if its currently in-use by another user. We can accomplish this by creating a dynamoDB table for terraform to use.

### Show me the code

The Terraform configuration on this directory creates the S3 bucket and DynamoDB table for storing and locking the Terraform state file remotely.  This is known as the [S3 backend](https://www.terraform.io/docs/backends/types/s3.html).

The S3 bucket is created in a particular AWS region.  The name of the S3 must be globally unique.  You can check its availability by checking this URL:

`https://<BUCKET NAME>.s3.amazonaws.com/`

It should output a XML with this content:
```
<Code>NoSuchBucket</Code>
<Message>The specified bucket does not exist</Message>
```

## Procedure to create the S3 backend:

1. Edit the [vars.tf](vars.tf) file to specify the region and bucket name.
2. Optionally edit the `dynamodb_name` variable in the [vars.tf](vars.tf) file.
3. Run `terraform init`
4. Run `terraform plan` to check whether the following command will succeed:
5. Run `terraform apply`
6. Add a [remote-state.tf](../remote-state.tf) file to your proyect.  Make sure that the values for the `bucket`, `dynamodb_table` and `region` are the same as the used in the [vars.tf](vars.tf) file.
7. In your proyect directory, run the command `terraform init` to reset the state file.
8. Run `terraform plan` to check whether the following command will succeed:
9. Run `terraform apply`
10. Check whether you can run `terraform destroy` from another directory or machine.

## Resources
- https://www.terraform.io/docs/backends/types/s3.html
- https://medium.com/@jessgreb01/how-to-terraform-locking-state-in-s3-2dc9a5665cb6
