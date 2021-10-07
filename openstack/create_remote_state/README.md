## Overview

### Store State Remotely

If you are working on a team, then its best to store the terraform state file remotely so that many people can access it. In order to setup terraform to store state remotely you need two things: a swift enabled OpenStack and a Terraform OpenStack backend resource.

## Procedure to create the OpenStack backend:

1. Rename the [remote-state.sample](../remote-state.sample) file to remote-state.tf inside your project.
2. Run `terraform init`
3. Run `terraform plan` to check whether the following command will succeed:
4. Run `terraform apply`
6. In your project directory, run the command `terraform init --upgrade` to reset the state file.
7. Run `terraform plan` to check whether the following command will succeed:
8. Run `terraform apply`
9. Check whether you can run `terraform destroy` from another directory or machine.

## Resources
- https://www.terraform.io/docs/language/settings/backends/swift.html
