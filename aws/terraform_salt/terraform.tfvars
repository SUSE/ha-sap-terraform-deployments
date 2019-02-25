# Launch SLES-HAE of SLES4SAP cluster nodes

# Instance type to use for the cluster nodes
instancetype = "m4.2xlarge"

# Number of nodes in the cluster
ninstances = "2"

# Region where to deploy the configuration
aws_region = "eu-central-1"

# SSH Public key to configure access to the remote instances
public_key = "ADD_YOUR_SSH_PUBLIC_KEY_HERE"

# Private SSH Key location
private_key_location = "/path/to/your/private/ssh/key"

# Custom AMI for iscsi_srv
#iscsi_srv = {
#    "eu-central-1" = "ami-xxxxxxxxxxxxxxxxx"
#}

# Custom AMI for nodes
#sles4sap = {
#    "eu-central-1" = "ami-xxxxxxxxxxxxxxxxx"
#}

# aws-cli credentials file. Located on ~/.aws/credentials on Linux, MacOS or Unix or at C:\Users\USERNAME\.aws\credentials on Windows
aws_credentials = "~/.aws/credentials"

# S3 bucket where HANA installation master is located
hana_inst_master = "s3://path/to/your/hana/installation/master"

# Local folder where HANA installation master will be downloaded from S3
hana_inst_folder = "/root/sap_inst/"

# Device used by node where HANA will be installed 
hana_disk_device = "/dev/xvdd"

# Variable for init-nodes.tpl script. Can be all, skip-hana or skip-cluster
init_type = "all"

# Device used by the iSCSI server to provide LUNs
iscsidev = "/dev/xvdd"

# Path to a custom ssh public key to upload to the nodes
# Used for cluster communication for example
cluster_ssh_pub = "salt://hana_node/files/sshkeys/cluster.id_rsa.pub"

# Path to a custom ssh private key to upload to the nodes
# Used for cluster communication for example
cluster_ssh_key = "salt://hana_node/files/sshkeys/cluster.id_rsa"

# Each host IP address (sequential order).
# example : host_ips = ["10.0.1.0", "10.0.1.1"]
host_ips = ["10.0.1.0", "10.0.1.1"]

# Optional SUSE Customer Center Registration parameters
#reg_code = "<<REG_CODE>>"
#reg_email = "<<your email>>"
#reg_additional_modules = {
#    "sle-module-adv-systems-management/12/x86_64" = ""
#    "sle-module-containers/12/x86_64" = ""
#    "sle-ha-geo/12.4/x86_64" = "<<REG_CODE>>"
#}

# QA variables

# If informed, register the product using SUSEConnect
# Mandatory to download salt-minion if it isn't include in the image
#qa_reg_code = "xxxxxxxxxxxxxxxx"

# Define if the deployement is using for testing purpose
# Disable all extra packages that do not come from the image
# Except salt-minion (for the moment) and salt formulas
# true or false
#qa_mode = "false"
