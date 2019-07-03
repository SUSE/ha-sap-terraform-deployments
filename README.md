# Automated SAP/HA Deployments in Public/Private Clouds with Terraform

[![Build Status](https://travis-ci.org/SUSE/ha-sap-terraform-deployments.svg?branch=master)](https://travis-ci.org/SUSE/ha-sap-terraform-deployments)
___
# Quickstart:

In this quickstart `libvirt` it is used  as example but same logic can be applied to other terraform providers.

0) `cd libvirt/terraform/`

1) Make sure you use terraform workspaces, create new one with: ```terraform workspace new $USER``` 

  For more doc, see: [workspace](workspaces-workflow.md). 
  If you don't create a new one, the string `default` will be used as workspace name. This is however highly discouraged since the workspace name is used as prefix for resources names, which can led to conflicts to unique names in a shared server ( when using a default name).

2) Edit the `terraform.tfvars.example` file, following the Readme.md in the provider directory.

3) Adapt pillars:

  Choose one profile, among the list. (in this example we choose `cost_optimized`)

  * from root top-level dir:
   `cp pillar_examples/libvirt/cost_optimized/*  salt/hana_node/files/pillar`

For more informations have a look at [pillar-doc](pillar_examples/README.md)

___
## Rationale:

This project is organized in folders containing the Terraform configuration files per Public or Private Cloud providers, each also containing documentation relevant to the use of the configuration files and to the cloud provider itself.

The documentation of terraform and the cloud providers included in this repository is not intended to be complete, so be sure to also check the [documentation provided by terraform](https://www.terraform.io/docs) and the cloud providers.

___
## Terraform version

All Terraform configurations were tested with the 0.11.14 version
