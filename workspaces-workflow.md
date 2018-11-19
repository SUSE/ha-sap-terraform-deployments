## Terraform Workspaces workflow

We now have remote state in the Terraform configuration for the following providers: AWS, Azure & Google.

This state is by definition shared, meaning that anyone with the correct credentials can destroy the infrastructure deployed by another user (or VM), whether we intend it or not.

To avoid accidental destruction and to support multiple and different deployments (for production, testing, etc.), Terraform has the concept of [Terraform workspaces](Terraform workspaces).

Some excerpts:

> Terraform starts with a single workspace named "default". This workspace is special both because it is the default and also because it cannot ever be deleted. If you've never explicitly used workspaces, then you've only ever worked on the "default" workspace.

> Non-default workspaces are often related to feature branches in version control. The default workspace might correspond to the "master" or "trunk" branch, which describes the intended state of production infrastructure. When a feature branch is created to develop a change, the developer of that feature might create a corresponding workspace and deploy into it a temporary "copy" of the main infrastructure so that changes can be tested without affecting the production infrastructure. Once the change is merged and deployed to the default workspace, the test infrastructure can be destroyed and the temporary workspace deleted.

> Workspaces are technically equivalent to renaming your state file. They aren't any more complex than that. Terraform wraps this simple notion with a set of protections and support for remote state.

The proposed workflow is the following:

  - Workspaces created by any user must be prefixed with `$USER-` and end with a simple but descriptive name for the deployment (e.g., `$USER-testing-ha`) or the GIT branch (e.g., `$USER-add-ha`).  In the case of OpenQA workers, it could be `openqa-$TEST_NUMBER`.

  - Where possible, the tags and labels of the resources created must be prefixed by the workspace, accessible with `${terraform.workspace}` to make it easier to remove resources from the web console when `terraform destroy` can not. Other resources may need to be renamed to conform to this nomenclature to avoid namespace clashes.

## TL;DR

To create a new workspace:

`terraform worspace new $USER-test-amazing-stuff`

Show current workspace:

`terraform workspace show`

To return to the default workspace:

`terraform workspace select default`

To list all workspaces:

`terraform workspace list`

To remove the previously created workspace:

`terraform workspace delete $USER-test-amazing-stuff`

Get help:

`terraform workspace help`
`terraform workspace SUBCOMMAND help`
