## Overview

### Store State Remotely

If you are working on a team, then its best to store the terraform state file remotely so that many people can access it. In order to setup terraform to store state remotely you need two things: a GCS bucket to store the state file in and a Terraform GCS backend resource.

### Show me the code

The Terraform configuration on this directory creates the GCS bucket for storing and locking the Terraform state file remotely.  This is known as the [GCS backend🔗](https://www.terraform.io/docs/backends/types/gcs.html).

The bucket name must be globally unique and conform to certain requirements described in [this document🔗](https://cloud.google.com/storage/docs/naming#requirements).

## Procedure to create the GCP backend:

1. Edit the [bucket.tf](bucket.tf) file to specify the `location` and bucket `name`.
2. Run `terraform init`
3. Run `terraform plan` to check whether the following command will succeed:
4. Run `terraform apply`
5. Rename the [remote-state.sample](../remote-state.sample) file to remote-state.tf inside your project. Make sure that the values for the `bucket` are the same.
6. In your project directory, run the command `terraform init --upgrade` to reset the state file.
7. Run `terraform plan` to check whether the following command will succeed:
8. Run `terraform apply`
9. Check whether you can run `terraform destroy` from another directory or machine.

## Resources
- https://www.terraform.io/docs/backends/types/gcs.html
