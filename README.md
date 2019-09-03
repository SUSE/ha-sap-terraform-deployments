# Automated SAP/HA Deployments in Public/Private Clouds with Terraform

[![Build Status](https://travis-ci.org/SUSE/ha-sap-terraform-deployments.svg?branch=master)](https://travis-ci.org/SUSE/ha-sap-terraform-deployments)
**Supported terraform version  `0.12.6`**
___

# Supported cloud providers:


- [libvirt/KVM](libvirt)
- [azure](azure)
- [google cloud](gcp)
- [aws](aws)

___
## Rationale:

This project is organized in folders containing the Terraform configuration files per Public or Private Cloud providers, each also containing documentation relevant to the use of the configuration files and to the cloud provider itself.

This project uses Terraform for the deployment and Saltstack for the provisioning.
