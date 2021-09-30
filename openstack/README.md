# OpenStack deployment with Terraform

- [quickstart](#quickstart)
- [highlevel description](#highlevel-description)
- [advanced usage](#advanced-usage)
- [monitoring](../doc/monitoring.md)
- [specification](#specification)

# Quickstart

1) **Rename terraform.tfvars:** `mv terraform.tfvars.example terraform.tfvars`

Now, the created file must be configured to define the deployment.

**Note:** Find some help in the IP addresses configuration in [IP autogeneration](../doc/ip_autogeneration.md#OpenStack)

2) **Generate private and public keys for the cluster nodes without specifying the passphrase:**

Alternatively, you can set the `pre_deployment` variable to automatically create the cluster ssh keys.
```
mkdir -p ../salt/sshkeys
ssh-keygen -f ../salt/sshkeys/cluster.id_rsa -q -P ""
```
The key files need to have same name as defined in [terraform.tfvars](terraform.tfvars.example)

3) **[Adapt saltstack pillars manually](../pillar_examples/)** or set the `pre_deployment` variable to automatically copy the example pillar files.

4) **Configure Terraform access to OpenStack**

- **Optional:** install openstack client (to use for environment variables), e.g.
  - configure `clouds.yaml` and `clouds-public.yaml`, [openstack client configuration reference](https://docs.openstack.org/python-openstackclient/latest/configuration/index.html#configuration-files)
  - example installation
```
pip install python-openstackclient
```

- export OpenStack environment variables (used by `infrastructure.tf`)
  - more details can be found in the [openstack command line reference](https://docs.openstack.org/python-openstackclient/latest/cli/man/openstack.html#environment-variables)
  - example configuration
```
export OS_CLOUD=my-lab
export TF_VAR_openstack_auth_url=$(openstack configuration show -c auth.auth_url -f value)
export TF_VAR_openstack_password=$(openstack configuration show -c auth.password -f value --unmask)
```

You should be able to deploy now.

To verify if you can access your OpenStack cloud, try a `openstack image list`.

5) **Prepare a NFS share with the installation sources**

Add the NFS paths to `terraform.tfvars`.

- **Note:** Find some help in [SAP software documentation](../doc/sap_software.md)

- **Optional:** enable NFS server on bastion host (see `terraform.tfvars`) and provision it before everything else. After that, copy files and proceed as usual.
```
terraform apply -target="module.bastion"
rsync -avPc --delete -e "ssh -l {admin_user} -i {private_key_location}" --rsync-path="sudo rsync" ~/Downloads/SAP/sapinst/ {bastion_ip}:/mnt_permanent/sapinst/
```

6) **Deploy**

```
terraform init
terraform workspace new myexecution # optional
terraform workspace select myexecution # optional
terraform plan
terraform apply
```

### Bastion

By default, the bastion machine is enabled in OpenStack (it can be disabled for private deployments), which will have the unique public IP address of the deployed resource group. Connect using ssh and the selected admin user with: ```ssh {admin_user}@{bastion_ip} -i {private_key_location}```

To log to hana and others instances, use:
```
ssh -o ProxyCommand="ssh -W %h:%p {admin_user}@{bastion_ip} -i {private_key_location} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" {admin_user}@{private_hana_instance_ip} -i {private_key_location} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
```

To disable the bastion use:

```bastion_enabled = false```

Destroy the created infrastructure with:

```
terraform destroy
```

# Highlevel description

This Terraform configuration deploys SAP HANA in a High-Availability Cluster on SUSE Linux Enterprise Server for SAP Applications in **OpenStack**.

The infrastructure deployed includes:

- A virtual network and subnetwork.
- Public IP access for the virtual machines via ssh.
- Network Security Groups for access to the instances created. The Bastion host will only be reachable via SSH. In the subnetwork any traffic is allowed.
- The definition of the image to use for the virtual machines.
- The definition of the flavor (size) to use for the virtual machines.
- Virtual machines to deploy.

By default, this configuration will create 3 instances in OpenStack: one for support services (mainly iSCSI) and 2 cluster nodes, but this can be changed to deploy more cluster nodes as needed.

Once the infrastructure is created by Terraform, the servers are provisioned with Salt.

# Specifications

In order to deploy the environment, different configurations are available through the terraform variables. These variables can be configured using a `terraform.tfvars` file. An example is available in [terraform.tfvars.example](./terraform.tvars.example). To find all the available variables check the [variables.tf](./variables.tf) file.

## QA deployment

The project has been created in order to provide the option to run the deployment in a `Test` or `QA` mode. This mode only enables the packages coming properly from SLE channels, so no other packages will be used. The mode is selected by setting the variable offline_mode to true.

## Pillar files configuration

Besides the `terraform.tfvars` file usage to configure the deployment, a more advanced configuration is available through pillar files customization. Find more information [here](../pillar_examples/README.md).

## Use already existing network resources

The usage of already existing network resources (subnet, firewall rules, etc) can be done configuring
the `terraform.tfvars` file and adjusting some variables. The example of how to use them is available
at [terraform.tfvars.example](terraform.tfvars.example).

# Advanced Usage
TODO
