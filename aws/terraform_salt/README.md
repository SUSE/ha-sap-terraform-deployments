
## AWS Public Cloud deployment with terraform and Salt

- [quickstart](#quickstart)
- [highlevel description](#highlevel-description)
- [advanced usage](#advanced-usage)
- [specification](#specification)

# Quickstart

1) **Rename terraform.tfvars** `mv terraform.tfvars.example terraform.tfvars`

2) **generate private and public keys for the cluster nodes with**

```
mkdir provision/hana_node/files/sshkeys; ssh-keygen -t rsa -f provision/hana_node/files/sshkeys/cluster.id_rsa
```

The key files need to have same name as defined in [terraform.tfvars](terraform.tfvars.example)

3) **Adapt saltstack pillars**:

  Choose one profile, among the list. (in this example we choose `cost_optimized`)

  * **from git top-level folder, copy files:**
`cp pillar_examples/aws/cost_optimized/*  salt/hana_node/files/pillar`

For more informations have a look at [pillar-doc](https://github.com/SUSE/ha-sap-terraform-deployments/tree/master/pillar_examples)


4) **Configure API access to AWS**

A pair of AWS API access key and secret key will be required;

there are several ways to configure the keys:


- env. variables

```
$ export AWS_ACCESS_KEY_ID="<HERE_GOES_THE_ACCESS_KEY>"
$ export AWS_SECRET_ACCESS_KEY="<HERE_GOES_THE_SECRET_KEY>"
$ export AWS_DEFAULT_REGION="eu-central-1"
$ terraform plan
```

- Credential file

Configure the values for the access key and the secret key in a credentials file located in `$HOME/.aws/credentials`. The syntax of the file is:

```
[default]
aws_access_key_id = <HERE_GOES_THE_ACCESS_KEY>
aws_secret_access_key = <HERE_GOES_THE_SECRET_KEY>
region = eu-central-1
```

This file is also used by the `aws` command line tool, so it can be created with the command: `aws configure`.

**Note**: All tests so far with this configuration have been done with only the keys stored in the credential files, and the region being passed as a variable.


5) **Deploy with**: 


```
terraform init
terraform plan
terraform apply
```

Destroy the created infrastructure with:

```
terraform destroy
```


# Highlevel description

The terraform configuration create the infrastructure needed for installation of a SAP HanaSR cluster with Suse Linux Enterprise Server for SAP Applications in *AWS*.

The infrastructure deployed includes:

- A Virtual Private Cloud
- A local subnet within the VPC
- A security group with rules for access to the instances created in the subnet. Only allowed external network traffic is for the protocols: SSH, HTTP, HTTPS, and for the HAWK service. Internally to the subnet, all traffic is allowed.
- An Internet gateway
- A route table with its corresponding associations.
- EC2 instances.

By default it create 3 instances in AWS: one for support services (mainly iSCSI as most other services - DHCP, NTP, etc - are provided by Amazon) and 2 cluster nodes, but this can be changed to deploy more cluster nodes as needed.

Once the infrastructure is created provisioning is made  with Salt in background.


# Specification:

These are the relevant files and what each provides:

- [provider.tf](provider.tf): definition of the providers being used in the terraform configuration. Mainly `aws` and `template`.

- [variables.tf](variables.tf): definition of variables used in the configuration. These include definition of the AMIs in use, number and type of instances, AWS region, etc.

- [keys.tf](keys.tf): definition of key to include in the instances to allow connection via SSH.

- [network.tf](network.tf): definition of network resources (VPC, route table, Internet Gateway and security group) used by the infrastructure.

- [instances.tf](instances.tf): definition of the EC2 instances to create on deployment.

- [salt_provisioner.tf](salt_provisioner.tf): salt provisioning resources.

- [salt_provisioner_script.tpl](../../salt/salt_provisioner_script.tpl): template code for the initialization script for the servers. This will add the salt-minion if needed and execute the SALT deployment.

- [outputs.tf](outputs.tf): definition of outputs of the terraform configuration.

- [remote-state.sample](remote-state.sample): sample file for the definition of the backend to [store the Terraform state file remotely](create_remote_state).

- [terraform.tfvars.example](terraform.tfvars.example): file containing initialization values for variables used throughout the configuration. **Rename/Duplicate this file to terraform.tfvars and edit the content with your values before use**.

#### Variables

In [terraform.tfvars](terraform.tfvars.example) there are a number of variables that control what is deployed. Some of these variables are:

* **instancetype**: instance type to use for the cluster nodes; basically the "size" (number of vCPUS and memory) of the instance. Defaults to `t2.micro`.
* **ninstances**: number of cluster nodes to deploy. Defaults to 2.
* **aws_region**: AWS region where to deploy the configuration.
* **public_key_location**: local path to the public SSH key associated with the private key file. This public key is configured in the file $HOME/.ssh/authorized_keys of the administration user in the remote virtual machines.
* **private_key_location**: local path to the private SSH key associated to the public key from the previous line.
* **aws_credentials**: path to the `aws-cli` credentials file. This is required to configure `aws-cli` in the instances so that they can access the S3 bucket containing the HANA installation master.
* **name**: hostname for the hana node without the domain part.
* **init-type**: initilization script parameter that controls what is deployed in the cluster nodes. Valid values are `all` (installs HANA and configures cluster), `skip-hana` (does not install HANA, but configures cluster) and `skip-cluster` (installs HANA, but does not configure cluster). Defaults to `all`.
* **hana_inst_master**: path to the `S3 Bucket` containing the HANA installation master.
* **hana_inst_folder**: path where HANA installation master will be downloaded from `S3 Bucket`.
* **hana_disk_device**: device used by node where HANA will be installed.
* **hana_fstype**: filesystem type used for HANA installation (xfs by default).
* **iscsidev**: device used by the iscsi server.
* **cluster_ssh_pub**: SSH public key name (must match with the key copied in sshkeys folder)
* **cluster_ssh_key**: SSH private key name (must match with the key copied in sshkeys folder)
* **ha_sap_deployment_repo**: Repository with HA and Salt formula packages. The latest RPM packages can be found at [https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/{YOUR OS VERSION}](https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/)
* **scenario_type**: SAP HANA scenario type. Available options: `performance-optimized` and `cost-optimized`.
* **provisioner**: select the desired provisioner to configure the nodes. Salt is used by default: [salt](../../salt). Let it empty to disable the provisioning part.
* **background**: run the provisioning process in background finishing terraform execution.
* **reg_code**: registration code for the installed base product (Ex.: SLES for SAP). This parameter is optional. If informed, the system will be registered against the SUSE Customer Center.
* **reg_email**: email to be associated with the system registration. This parameter is optional.
* **reg_additional_modules**: additional optional modules and extensions to be registered (Ex.: Containers Module, HA module, Live Patching, etc). The variable is a key-value map, where the key is   the _module name_ and the value is the _registration code_. If the _registration code_ is not needed,  set an empty string as value. The module format must follow SUSEConnect convention:
    - `<module_name>/<product_version>/<architecture>`
    - *Example:* Suggested modules for SLES for SAP 15

          sle-module-basesystem/15/x86_64
          sle-module-desktop-applications/15/x86_64
          sle-module-server-applications/15/x86_64
          sle-ha/15/x86_64 (use the same regcode as SLES for SAP)
          sle-module-sap-applications/15/x86_64

 For more information about registration, check the ["Registering SUSE Linux Enterprise and Managing Modules/Extensions"](https://www.suse.com/documentation/sles-15/book_sle_deployment/data/cha_register_sle.html) guide.

* **additional_repos**: Additional repos to add to the guest machines.
* **additional_packages**: Additional packages to add to the guest machines.
* **hosts_ips**: Each cluster nodes IP address (sequential order). Mandatory to have a generic `/etc/hosts` file.

 Specific QA variable
* **qa_mode**: If set to true, it disables extra packages not already present in the image. For example, set this value to true if performing the validation of a new AWS Public Cloud image.


### Relevant Details

There are some fixed values used throughout the terraform configuration:

- The private IP address of the iSCSI server is set to 10.0.0.254.
- The cluster nodes are created with private IPs starting with 10.0.1.0 and on. The instance running with 10.0.1.0 is used initially as the master node of the cluster, ie, the node where `ha-cluster-init` is run.
- The iSCSI server has a second disk volume that is being used as a shared device.
- Salt is partitioning this device in 5 x 1MB partitions and then configuring just the LUN 0 for iSCSI (improvement is needed in iscsi-formula to create more than one device). **Until this improvement is added, an iscsi config file (/etc/target/saveconfig.json) is loaded when the qa_mode is set to true to configure 5 more LUN, mandatory for other tests like DRBD.**
- iSCSI LUN 0 is being used in the cluster as SBD device.
- The cluster nodes have a second disk volume that is being used for Hana installation.

# Advanced Usage


# notes:

**Important**: If you want to use remote terraform states, first follow the [procedure to create a remote terraform state](create_remote_state).

This configuration uses the public **SUSE Linux Enterprise Server 15 for SAP Applications BYOS x86_64** image available in AWS (as defined in the file [variables.tf](variables.tf)) and can be used as is.

If the use of a private/custom image is required (for example, to perform the Build Validation of a new AWS Public Cloud image), first upload the image to the cloud using the [procedure described below](#upload-image-to-aws), and then [register it as an AMI](#import-ami-via-snapshot). Once the new AMI is available, edit its AMI id value in the [terraform.tfvars](terraform.tfvars.example) file for your region of choice.

**Important:** The image used for the iSCSI server **must be at least SLES 15 version** since the iSCSI salt formula is not compatible with lower versions.

To define the custom AMI in terraform, you should use the [terraform.tfvars](terraform.tfvars.example) file:
```
 # Custom AMI for nodes
sles4sap = {
    "eu-central-1" = "ami-xxxxxxxxxxxxxxxxx"
}
```


After an `apply` command, terraform will deploy the insfrastructure to the cloud and ouput the public IP addresses and names of the iSCSI server and the cluster nodes. Connect using `ssh` as the user `ec2-user`, for example:

```
ssh ec2-user@18.196.143.128
```


By default this configuration will deploy the infrastructure to the `eu-central-1` region of AWS. Internally, the provided terraform files are only configured for the European (eu-central-1, eu-west-1, eu-west-2 and eu-west-3) and North American zones (us-east-1, us-east-2, us-west-1, us-west-2 and ca-central-1), but this as well as the default zone can be changed by editing the [variables.tf](variables.tf) or the [terraform.tfvars](terraform.tfvars.example) files.

It is also possible to change the AWS region from the command line with the `-var aws_region` parameter, for example:

```
terraform apply -var aws_region=eu-central-1
```

Will deploy the insfrastructure in Frankfurt.

The EC2 instances for the cluster nodes are created by default with the type `m4.2xlarge`, this can be changed with the option `-var instancetype`. For example:

```
terraform apply -var aws_region=eu-central-1 -var instancetype=m4.large
```

Will deploy 2 `m4.large` instances in Frankfurt, instead of the `m4.2xlarge` default ones. The iSCSI server is always deployed with the `t2.micro` type instance.

Finally, the number of cluster nodes can be modified with the option `-var ninstances`. For example:

```
terraform apply -var aws_region=eu-central-1 -var ninstances=4
```

Will deploy in Frankfurt 1 `t2.micro` instance as an iSCSI server, and 4 `m4.2xlarge` instances as cluster nodes.

All this means that basically the default command `terraform apply` and be also written as `terraform apply -var instancetype=m4.2xlarge -var ninstances=2`.



## Upload image to AWS

Instead of the public OS images referenced in this configuration, the EC2 instances can also be launched using a private OS images as long as it is uploaded to AWS as a Amazon Machine Image (AMI). These images have to be in raw format.

In order to upload the raw images as an AMI, first an Amazon S3 bucket is required to store the raw image. This can be created with the following command using the aws-cli (remember to configure aws-cli access with `aws configure`):

```
aws s3 mb s3://instmasters --region eu-central-1
```

This creates an S3 bucket called `instmasters`, which will be used during the rest of this document. Verify the existing S3 buckets in the account with `aws s3 ls`.

After the bucket has been created, the next step is to copy the raw image file to the bucket; be sure to decompress it before uploading it to the S3 bucket:

```
unxz SLES12-SP4-SAP-EC2-HVM-BYOS.x86_64-0.9.2-Build1.1.raw.xz
aws s3 cp SLES12-SP4-SAP-EC2-HVM-BYOS.x86_64-0.9.2-Build1.1.raw s3://instmasters/
```

The above example is using the SLES 12-SP4 for SAP for EC2 BYOS raw image file. Substitute that with the file name of the image you wish to test.

## Create AMI

### IAM Role creation and setup

Once the raw image file is in an Amazon S3 bucket, the next step is to create an IAM role and policy to allow the import of images.

First, create a `trust-policy.json` file with the following content:

```
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": { "Service": "vmie.amazonaws.com" },
         "Action": "sts:AssumeRole",
         "Condition": {
            "StringEquals":{
               "sts:Externalid": "vmimport"
            }
         }
      }
   ]
}
```

Then, create a `role-policy.json` file with the following content:

```
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket"
         ],
         "Resource":[
            "arn:aws:s3:::instmasters",
            "arn:aws:s3:::instmasters/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource":"*"
      }
   ]
}
```

Note that the `role-policy.json` file references the `instmasters` S3 Bucket, so change that value accordingly.

Once the files have been created, run the following commands to create the `vmimport` role and to put the role policy into it:

```
aws iam create-role --role-name vmimport --assume-role-policy-document file://trust-policy.json
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file://role-policy.json
```

Check the output of the commands for any errors.

### Import AMI

To import the raw image into an AMI, the command `aws ec2 import-image` needs to be called. This command requires a disk containers file which specifies the location of the raw image file in the S3 Bucket, as well as the description of the AMI to import.

First create a `container.json` file with the following content:

```
[
  {
     "Description": "SLES4SAP 12-SP4 Beta4 Build 1.1",
     "Format": "raw",
     "UserBucket": {
         "S3Bucket": "instmasters",
         "S3Key": "SLES12-SP4-SAP-EC2-HVM-BYOS.x86_64-0.9.2-Build1.1.raw"
     }
  }
]
```

Substitute the values for `Description`, `S3Bucket` and `S3Key` with the values corresponding to the image you wish to upload and the S3 Bucket where the raw file is located.

Once the file is created, import the image with the command:

```
aws ec2 import-image --description "SLES4SAP 12-SP4 Beta4 Build 1.1" --license BYOL --disk-containers file://container.json
```

Again, substitute the description with the description text of the image you will be testing.

The output of the `aws ec2 import-image` should look like this:

```
{
    "Status": "active",
    "LicenseType": "BYOL",
    "Description": "SLES4SAP 12-SP4 Beta4 Build 1.1",
    "Progress": "2",
    "SnapshotDetails": [
        {
            "UserBucket": {
                "S3Bucket": "instmasters",
                "S3Key": "SLES12-SP4-SAP-EC2-HVM-BYOS.x86_64-0.9.2-Build1.1.raw"
            },
            "DiskImageSize": 0.0,
            "Format": "RAW"
        }
    ],
    "StatusMessage": "pending",
    "ImportTaskId": "import-ami-0e6e37788ae2a340b"
}
```

This will say that the import process is active and that it is pending, so you will need the `aws ec2 describe-import-image-tasks` command to check the progress. For example:

```
$ aws ec2 describe-import-image-tasks --import-task-ids import-ami-0e6e37788ae2a340b
{
    "ImportImageTasks": [
        {
            "Status": "active",
            "Description": "SLES4SAP 12-SP4 Beta4 Build 1.1",
            "Progress": "28",
            "SnapshotDetails": [
                {
                    "Status": "active",
                    "UserBucket": {
                        "S3Bucket": "instmasters",
                        "S3Key": "SLES12-SP4-SAP-EC2-HVM-BYOS.x86_64-0.9.2-Build1.1.raw"
                    },
                    "DiskImageSize": 10737418240.0,
                    "Description": "SLES4SAP 12-SP4 Beta4 Build 1.1",
                    "Format": "RAW"
                }
            ],
            "StatusMessage": "converting",
            "ImportTaskId": "import-ami-0e6e37788ae2a340b"
        }
    ]
}
```

Wait until the status is **completed** and search for the image id to use in the test. This image id (a string starting with `ami-`) should be added to the file [variables.tf](variables.tf) in order to be used in the terraform configuration included here.

### Import AMI via snapshot

An alternate way to convert a raw image into an AMI is to first upload a snapshot of the raw image, and then convert the snapshot into an AMI. This is helpful sometimes as it bypasses some checks performed by `aws ec2 import-image` such as kernel version checks.

First, create a `container-snapshot.json` file with the following content:

```
{
     "Description": "SLES4SAP 12-SP4 Beta4 Build 1.1",
     "Format": "raw",
     "UserBucket": {
         "S3Bucket": "instmasters",
         "S3Key": "SLES12-SP4-SAP-EC2-HVM-BYOS.x86_64-0.9.2-Build1.1.raw"
     }
}
```

Notice that the syntax of the `container.json` file and the `container-snapshot.json` file are mostly the same, with the exception of the opening and closing brackets on the `container.json` file.

Substitute the Description, S3Bucket and S3Key for the correct values of the image to validate. In the case of the `instmasters` bucket, the S3Key can be found with `aws s3 ls s3://instmasters`.

Once the file has been created, import the snapshot with the following command:

```
aws ec2 import-snapshot --description "SLES4SAP 12-SP4 Beta4 Build 1.1" --disk-container file://container-snapshot.json
```

The output of this command should look like this:

```
{
    "SnapshotTaskDetail": {
        "Status": "active",
        "Description": "SLES4SAP 12-SP4 Beta4 Build 1.1",
        "Format": "RAW",
        "DiskImageSize": 0.0,
        "Progress": "3",
        "UserBucket": {
            "S3Bucket": "instmasters",
            "S3Key": "SLES12-SP4-SAP-EC2-HVM-BYOS.x86_64-0.9.2-Build1.1.raw"
        },
        "StatusMessage": "pending"
    },
    "Description": "SLES4SAP 12-SP4 Beta4 Build 1.1",
    "ImportTaskId": "import-snap-0fbbe899f2fd4bbdc"
}
```

Similar to the `import-image` command, the process stays runing in the background in AWS. You can check its progress with the command:

```
aws ec2 describe-import-snapshot-tasks --import-task-ids import-snap-0fbbe899f2fd4bbdc
```

Be sure to use the proper `ImportTaskId` value from the output of your `aws ec2 import-snapshot` command.

When the process is completed, the `describe-import-snapshot-tasks` command will output something like this:

```
{
    "ImportSnapshotTasks": [
        {
            "SnapshotTaskDetail": {
                "Status": "completed",
                "Description": "SLES4SAP 12-SP4 Beta4 Build 1.1",
                "Format": "RAW",
                "DiskImageSize": 10737418240.0,
                "SnapshotId": "snap-0a369f803b17037bb",
                "UserBucket": {
                    "S3Bucket": "instmasters",
                    "S3Key": "SLES12-SP4-SAP-EC2-HVM-BYOS.x86_64-0.9.2-Build1.1.raw"
                }
            },
            "Description": "SLES4SAP 12-SP4 Beta4 Build 1.1",
            "ImportTaskId": "import-snap-0fbbe899f2fd4bbdc"
        }
    ]
}
```

Notice the **completed** status in the above JSON output.

Also notice tne `SnapshotId` which will be used in the next step to register the AMI.

Once the snapshot is completely imported, the next step is to register an AMI with the command:

```
aws ec2 register-image --architecture x86_64 --description "SLES 12-SP4 Beta4 Build 1.1" --name sles-12-sp4-b4-b1.1 --root-device-name "/dev/sda1" --virtualization-type hvm --block-device-mappings "DeviceName=/dev/sda1,Ebs={DeleteOnTermination=true,SnapshotId=snap-0a369f803b17037bb,VolumeSize=40,VolumeType=gp2}"
```

Substitute in the above command line the description, name and snapshot id with the apropiate values for your image.

The output, should include the image id. This image id (a string starting with `ami-`) should be added to the file [variables.tf](variables.tf) in order to be used in the terraform configuration included here.

More information regarding the import of images into AWS can be found in [this Amazon document](https://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html) or in [this blog post](https://www.wavether.com/2016/11/import-qcow2-images-into-aws).

Examples of the JSON files used in this document have been added to this repo.

## Logs

This configuration is leaving logs in /tmp folder in each of the instances. Connect as `ssh ec2-user@<remote_ip>`, then do a `sudo su -` and check the following files:

* **/tmp/provisioning.log**: This is the global log file, inside it you will find the logs for user_data, salt-deployment and salt-formula.
* **/tmp/salt-deployment.log**: Check here the debug log for the salt-deployment if you need to troubleshoot something.
* **/tmp/salt-formula.log**: Same as above but for salt-formula.
