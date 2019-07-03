# Automated SAP/HA Deployments in Public/Private Clouds with Terraform

[![Build Status](https://travis-ci.org/SUSE/ha-sap-terraform-deployments.svg?branch=master)](https://travis-ci.org/SUSE/ha-sap-terraform-deployments)

# Quick-start:

1) Make sure you use a [workspace](workspaces-workflow.md). 
   If you don't create a new one, `default` name will be used. This is however highly discouraged since the workspace name is used as prefix for resources names, which can led to conflicts to unique names in a shared server ( when using a default name).

2) Change to the provider directory of your choice and follow instructions there.

## Rationale:

This project is organized in folders containing the Terraform configuration files per Public or Private Cloud providers, each also containing documentation relevant to the use of the configuration files and to the cloud provider itself.

The documentation of terraform and the cloud providers included in this repository is not intended to be complete, so be sure to also check the [documentation provided by terraform](https://www.terraform.io/docs) and the cloud providers.


## Deploying with Salt

In order to execute the deployment with salt follow the instructions in [README](pillar_examples/README.md)

## Terraform version

All Terraform configurations were tested with the 0.11.14 version
