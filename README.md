# Automated SAP/HA Deployments in Public/Private Clouds with Terraform

[![Build Status](https://github.com/SUSE/ha-sap-terraform-deployments/workflows/CI%20tests/badge.svg)](https://github.com/SUSE/ha-sap-terraform-deployments/actions)

**Supported terraform version  `0.13.4`**
___

# Supported cloud providers

- [libvirt/KVM](libvirt)
- [azure](azure)
- [google cloud](gcp)
- [aws](aws)
- [OpenStack](openstack)


## Major features

- HA Clusters and HANA deployment
- [Preparing SAP software](doc/sap_software.md)
- [Monitoring of cluster](doc/monitoring.md)
- [S/4HANA and NetWeaver](doc/netweaver.md)
- [DRBD](doc/drbd.md)
- [Saptune](doc/saptune.md)
- [Fencing mechanism](doc/fencing.md)
- [IP addresses auto generation](doc/ip_autogeneration.md)

## Templates

We provide minimal templates for setting up the terraform variables in order to get started with the project.
For fine tuning refer to variable specification.

- [templates](doc/deployment-templates.md)

## Design

This project is based in [terraform](https://www.terraform.io/) and [salt](https://www.saltstack.com/) usage.

Components:

- **terraform**: Terraform is used to create the required infrastructure in the specified provider. The code is divided in different terraform modules to make the code modular and more maintanable.
- **salt**: Salt configures all the created machines by terraform based in the provided pillar files that give the option to customize the deployment.

## Components

The project can deploy and configure the next components (they can be enabled/disabled through configuration options):

- SAP HANA environment: The HANA deployment is configurable. It might be deployed as a single HANA database, a dual configuration with system replication, and a HA cluster can be set in top of that.
- ISCSI server: The ISCSI server provides a network based storage mostly used by sbd fencing mechanism.
- Monitoring services server: The monitoring solution is based in [prometheus](https://prometheus.io) and [grafana](https://grafana.com/) and it provides informative and customizable dashboards to the users and administrators.
- DRBD cluster: The DRBD cluster is used to mount a HA NFS server in top of it to mount NETWEAVER shared files.
- SAP NETWEAVER environment: A SAP NETWEAVER environment with ASCS, ERS, PAS and AAS instances can be deployed using HANA database as storage.

## Project structure

This project is organized in folders containing the Terraform configuration files per Public or Private Cloud providers, each also containing documentation relevant to the use of the configuration files and to the cloud provider itself.

This project uses Terraform for the deployment and Saltstack for the provisioning.

**Be careful with what instance type you will use because default choice is systems certified by SAP, so cost could be expensive if you leave the default value.**

These are links to find certified systems for each provider:

- [SAP Certified IaaS Platforms for AWS](https://www.sap.com/dmc/exp/2014-09-02-hana-hardware/enEN/iaas.html#categories=Amazon%20Web%20Services)

- [SAP Certified IaaS Platforms for GCP](https://www.sap.com/dmc/exp/2014-09-02-hana-hardware/enEN/iaas.html#categories=Google%20Cloud%20Platform)

- [SAP Certified IaaS Platforms for Azure](https://www.sap.com/dmc/exp/2014-09-02-hana-hardware/enEN/iaas.html#categories=Microsoft%20Azure) (Be carreful with Azure, **clustering** means scale-out scenario)


## Troubleshooting

In the case you have some issue, take a look at the [troubleshooting guide](doc/troubleshooting.md)
