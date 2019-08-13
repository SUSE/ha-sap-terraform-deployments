# What is the difference between terraform and terraform_salt?

- The `terraform` directory contains the terraform files that don't use SaltStack as provisioner, its existence is related to historical reasons.

- The `terraform_salt` contains the terraform files that use SaltStack as provisioner.

Use by preference always `terraform_salt` when possible.
