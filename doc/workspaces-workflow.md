## Terraform Workspaces workflow

We now have remote state in the Terraform configuration for the following providers: AWS, Azure & Google.

This state is by definition shared, meaning that anyone with the correct credentials can destroy the infrastructure deployed by another user (or VM), whether we intend it or not.

To avoid accidental destruction and to support multiple and different deployments (for production, testing, etc.), Terraform has the concept of [Terraform workspaces](Terraform workspaces).

Some excerpts:

> Terraform starts with a single workspace named "default". This workspace is special both because it is the default and also because it cannot ever be deleted. If you've never explicitly used workspaces, then you've only ever worked on the "default" workspace.

> Non-default workspaces are often related to feature branches in version control. The default workspace might correspond to the "master" or "trunk" branch, which describes the intended state of production infrastructure. When a feature branch is created to develop a change, the developer of that feature might create a corresponding workspace and deploy into it a temporary "copy" of the main infrastructure so that changes can be tested without affecting the production infrastructure. Once the change is merged and deployed to the default workspace, the test infrastructure can be destroyed and the temporary workspace deleted.

> Workspaces are technically equivalent to renaming your state file. They aren't any more complex than that. Terraform wraps this simple notion with a set of protections and support for remote state.


```IMPORTANT```: the terraform workspace name **must not contain** `-` or `_` characters.  Otherwise you will encounter failures by different cloud providers

## TL;DR

To create a new workspace:

`terraform worspace new $USER`

Show current workspace:

`terraform workspace show`

To return to the default workspace:

`terraform workspace select default`

To list all workspaces:

`terraform workspace list`

To remove the previously created workspace:

`terraform workspace delete $USER`

Get help:

`terraform workspace help`
`terraform workspace SUBCOMMAND help`
