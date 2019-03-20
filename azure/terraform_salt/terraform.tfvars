# Instance type to use for the cluster nodes
instancetype = "Standard_E4s_v3"

# Number of nodes in the cluster
ninstances = "2"

# Region where to deploy the configuration
az_region = "westeurope"

admin_user = "your-user"

# SSH Public key to configure access to the remote instances
public_key_location = "your-public-key-location"

# Private SSH Key location
private_key_location = "your-private-key-location"

# Azure storage account name
storage_account_name = "your-storage-account-name"

# Azure storage account secret key (key1 or key2)
storage_account_key = "your-storage-account-key"

# Azure storage account path
hana_inst_master = "your-storage-account-path"

# Local folder where HANA installation master will be mounted
hana_inst_folder = "/root/sap_inst/"

# Device used by node where HANA will be installed
hana_disk_device = "/dev/sdc"

# Variable for init-nodes.sh script
init-type = "all"

# Device used by the iSCSI server to provide LUNs
iscsidev = "/dev/sdc"

# Path to a custom ssh public key to upload to the nodes
# Used for cluster communication for example
cluster_ssh_pub = "salt://hana_node/files/sshkeys/cluster.id_rsa.pub"

# Path to a custom ssh private key to upload to the nodes
# Used for cluster communication for example
cluster_ssh_key = "salt://hana_node/files/sshkeys/cluster.id_rsa"

# Each host IP address (sequential order).
# example : host_ips = ["10.0.1.0", "10.0.1.1"]
host_ips = ["10.74.1.11", "10.74.1.12"]

# HA packages Repository
ha_sap_deployment_repo = "your-ha-repo"

# Optional SUSE Customer Center Registration parameters
reg_code = "your-reg-code"
reg_email = "your-mail"
#reg_additional_modules = {
#    "sle-module-adv-systems-management/12/x86_64" = ""
#    "sle-module-containers/12/x86_64" = ""
#    "sle-ha-geo/12.4/x86_64" = "<<REG_CODE>>"
#}

# QA variables

# Define if the deployement is using for testing purpose
# Disable all extra packages that do not come from the image
# Except salt-minion (for the moment) and salt formulas
# true or false
#qa_mode = "false"
