variable "region" {
  description = "OpenStack Availability Zone region where the deployment machines will be created"
  type        = string
  default     = "south-1"
}

variable "region_net" {
  description = "OpenStack Availability Zone region where the networks will be created"
  type        = string
  default     = "south-1"
}

variable "external_network_id" {
  description = "Already existing external network id in openstack"
  type        = string
  default     = ""
}

variable "floatingip_pool" {
  description = "Already existing floating IP pool in openstack"
  type        = string
  default     = ""
}

variable "network_name" {
  description = "Already existing network name used by the created infrastructure. If it's not set a new one will be created"
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created"
  type        = string
  default     = ""
}

variable "network_id" {
  description = "Network ID to attach the static route (temporary solution)"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID to attach the network interface of the nodes"
  type        = string
  default     = ""
}

variable "firewall_external" {
  description = "External firewall to attach VM to"
  type        = string
  default     = ""
}

variable "firewall_internal" {
  description = "Internal firewall to attach VM to"
  type        = string
  default     = ""
}

variable "create_firewall_rules" {
  description = "Create predefined firewall rules for the connections outside the network (internal connections are always allowed). Set to false if custom firewall rules are already created for the used network"
  type        = bool
  default     = true
}

variable "ip_cidr_range" {
  description = "Internal IPv4 range of the created network"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_key" {
  description = "Content of a SSH public key or path to an already existing SSH public key. The key is only used to provision the machines and it is authorized for future accesses"
  type        = string
}

variable "private_key" {
  description = "Content of a SSH private key or path to an already existing SSH private key. The key is only used to provision the machines. It is not uploaded to the machines in any case"
  type        = string
}

variable "authorized_keys" {
  description = "List of additional authorized SSH public keys content or path to already existing SSH public keys to access the created machines with the used admin user (root in this case)"
  type        = list(string)
  default     = []
}

variable "bastion_name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "vmbastion"
}

variable "bastion_network_domain" {
  description = "hostname's network domain"
  type        = string
  default     = ""
}

variable "bastion_enabled" {
  description = "Create a VM to work as a bastion to avoid the usage of public ip addresses and manage the ssh connection to the other machines"
  type        = bool
  default     = true
}

variable "bastion_srv_ip" {
  description = "Bastion server address"
  type        = string
  default     = ""
}

variable "bastion_flavor" {
  description = "The instance type of the bastion node"
  type        = string
  default     = "2C-2GB-40GB"
}

variable "bastion_data_disk_name" {
  description = "Use existing volume to mount on bastion for NFS server"
  type        = string
  default     = ""
}

variable "bastion_data_disk_type" {
  description = "Disk type of the disks used to serve as NFS server"
  type        = string
  default     = ""
}

variable "bastion_data_disk_size" {
  description = "Disk Size of the disks used to serve as NFS server"
  type        = string
  default     = "50"
}

variable "bastion_os_image" {
  description = "sles4sap image used to create the bastion machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp2:gen2:latest"
  type        = string
  default     = ""
}

variable "bastion_public_key" {
  description = "Content of a SSH public key or path to an already existing SSH public key to the bastion. If it's not set the key provided in public_key will be used"
  type        = string
  default     = ""
}

variable "bastion_private_key" {
  description = "Content of a SSH private key or path to an already existing SSH private key to the bastion. If it's not set the key provided in private_key will be used"
  type        = string
  default     = ""
}

# Deployment variables

variable "deployment_name" {
  description = "Suffix string added to some of the infrastructure resources names. If it is not provided, the terraform workspace string is used as suffix"
  type        = string
  default     = ""
}

variable "deployment_name_in_hostname" {
  description = "Add deployment_name as a prefix to all hostnames."
  type        = bool
  default     = true
}

variable "network_domain" {
  description = "hostname's network domain for all hosts. Can be overwritten by modules."
  type        = string
  default     = "tf.local"
}

variable "os_image" {
  description = "Default OS image for all the machines. This value is not used if the specific nodes os_image is set (e.g. hana_os_image)"
  type        = string
  default     = "suse-sap-cloud/sles-15-sp2-sap"
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

variable "reg_code" {
  description = "If informed, register the product using SUSEConnect"
  type        = string
  default     = ""
}

variable "reg_email" {
  description = "Email used for the registration"
  default     = ""
}

# The module format must follow SUSEConnect convention:
# <module_name>/<product_version>/<architecture>
# Example: Suggested modules for SLES for SAP 15
# - sle-module-basesystem/15/x86_64
# - sle-module-desktop-applications/15/x86_64
# - sle-module-server-applications/15/x86_64
# - sle-ha/15/x86_64 (Need the same regcode as SLES for SAP)
# - sle-module-sap-applications/15/x86_64

variable "reg_additional_modules" {
  description = "Map of the modules to be registered. Module name = Regcode, when needed."
  type        = map(string)
  default     = {}
}

variable "additional_packages" {
  description = "Extra packages to be installed"
  default     = []
}

# Repository url used to install development versions of HA/SAP deployment packages
# The latest RPM packages can be found at:
# https://download.opensuse.org/repositories/network:ha-clustering:sap-deployments:devel/{YOUR SLE VERSION}
# Contains the salt formulas rpm packages.
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install development versions of HA/SAP deployment packages. If the SLE version is not present in the URL, it will be automatically detected"
  type        = string
  default     = ""
}

variable "cluster_ssh_pub" {
  description = "Path to a SSH public key used during the cluster creation. The key must be passwordless"
  type        = string
}

variable "cluster_ssh_key" {
  description = "Path to a SSH private key used during the cluster creation. The key must be passwordless"
  type        = string
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "provisioning_log_level" {
  description = "Provisioning process log level. For salt: https://docs.saltstack.com/en/latest/ref/configuration/logging/index.html"
  type        = string
  default     = "error"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  type        = bool
  default     = false
}

variable "provisioning_output_colored" {
  description = "Print colored output of the provisioning execution"
  type        = bool
  default     = true
}

# Hana related variables

variable "hana_name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "vmhana"
}

variable "hana_network_domain" {
  description = "hostname's network domain"
  type        = string
  default     = ""
}

variable "hana_count" {
  description = "Number of hana nodes"
  type        = string
  default     = "2"
}

variable "hana_flavor" {
  description = "The instance type of the hana nodes"
  type        = string
  default     = "2C-2GB-40GB"
}

variable "hana_os_image" {
  description = "The image used to create the hana machines"
  type        = string
  default     = ""
}

variable "hana_ips" {
  description = "ip addresses to set to the hana nodes. They must be in the same network addresses range defined in `ip_cidr_range`"
  type        = list(string)
  default     = []
}

variable "hana_inst_master" {
  description = "GCP storage bucket that contains the SAP HANA installation files"
  type        = string
}

variable "hana_inst_folder" {
  description = "Folder where the hana installation software will be downloaded"
  type        = string
  default     = "/sapmedia/HANA"
}

variable "hana_platform_folder" {
  description = "Path to the hana platform media, relative to the 'hana_inst_master' mounting point"
  type        = string
  default     = ""
}

variable "hana_sapcar_exe" {
  description = "Path to the sapcar executable, relative to the 'hana_inst_master' mounting point. Only needed if HANA installation software comes in a SAR file (like IMDB_SERVER.SAR)"
  type        = string
  default     = ""
}

variable "hana_archive_file" {
  description = "Path to the HANA database server installation SAR archive (for SAR files, `hana_sapcar_exe` variable is mandatory) or HANA platform archive file in ZIP or RAR (EXE) format, relative to the 'hana_inst_master' mounting point. Use this parameter if the HANA media archive is not already extracted"
  type        = string
  default     = ""
}

variable "hana_extract_dir" {
  description = "Absolute path to folder where SAP HANA archive will be extracted. This folder cannot be the same as `hana_inst_folder`!"
  type        = string
  default     = "/sapmedia_extract/HANA"
}

variable "hana_client_folder" {
  description = "Path to the extracted HANA Client folder, relative to the 'hana_inst_master' mounting point"
  type        = string
  default     = ""
}

variable "hana_client_archive_file" {
  description = "Path to the HANA Client SAR archive , relative to the 'hana_inst_master' mounting point. Use this parameter if the HANA Client archive is not already extracted"
  type        = string
  default     = ""
}

variable "hana_client_extract_dir" {
  description = "Absolute path to folder where SAP HANA Client archive will be extracted"
  type        = string
  default     = "/sapmedia_extract/HANA_CLIENT"
}

variable "hana_sid" {
  description = "System identifier of the HANA system. It must be a 3 characters string (check the restrictions in the SAP documentation pages). Examples: PRD, HA1"
  type        = string
  default     = "PRD"
}

variable "hana_cost_optimized_sid" {
  description = "System identifier of the HANA cost-optimized system. It must be a 3 characters string (check the restrictions in the SAP documentation pages). Examples: PRD, HA1"
  type        = string
  default     = "QAS"
}

variable "hana_instance_number" {
  description = "Instance number of the HANA system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "00"
}

variable "hana_cost_optimized_instance_number" {
  description = "Instance number of the HANA cost-optimized system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "01"
}

variable "hana_master_password" {
  description = "Master password for the HANA system (sidadm user included)"
  type        = string
}

variable "hana_cost_optimized_master_password" {
  description = "Master password for the HANA system (sidadm user included)"
  type        = string
  default     = ""
}

variable "hana_primary_site" {
  description = "HANA system replication primary site name"
  type        = string
  default     = "Site1"
}

variable "hana_secondary_site" {
  description = "HANA system replication secondary site name"
  type        = string
  default     = "Site2"
}

variable "hana_cluster_vip" {
  description = "IP address used to configure the hana cluster floating IP. It must be in other subnet than the machines!"
  type        = string
  default     = ""
}

variable "hana_cluster_fencing_mechanism" {
  description = "Select the HANA cluster fencing mechanism. Options: sbd, native"
  type        = string
  default     = "sbd"
}

variable "hana_ha_enabled" {
  description = "Enable HA cluster in top of HANA system replication"
  type        = bool
  default     = true
}

variable "hana_active_active" {
  description = "Enable an Active/Active HANA system replication setup"
  type        = bool
  default     = false
}

variable "hana_cluster_vip_secondary" {
  description = "IP address used to configure the hana cluster floating IP for the secondary node in an Active/Active mode. Let empty to use an auto generated address"
  type        = string
  default     = ""
}

variable "hana_data_disk_type" {
  description = "Disk type of the disks used to store hana database content"
  type        = string
  default     = "pd-ssd"
}

variable "hana_data_disk_size" {
  description = "Disk size of the disks used to store hana database content"
  type        = string
  default     = "896"
}

variable "hana_backup_disk_type" {
  description = "Disk type of the disks used to store hana database backup content"
  type        = string
  default     = "pd-standard"
}

variable "hana_backup_disk_size" {
  description = "Disk size of the disks used to store hana database backup content"
  type        = string
  default     = "128"
}

variable "hana_fstype" {
  description = "Filesystem type used by the disk where hana is installed"
  type        = string
  default     = "xfs"
}

variable "hana_ignore_min_mem_check" {
  description = "Disable the min mem check imposed by hana allowing it to run with under 24 GiB"
  type        = bool
  default     = false
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
}

variable "hana_scale_out_enabled" {
  description = "Enable HANA scale out deployment"
  type        = bool
  default     = false
}

variable "hana_scale_out_shared_storage_type" {
  description = "Storage type to use for HANA scale out deployment - not supported for this cloud provider yet"
  type        = string
  default     = ""
  validation {
    condition = (
      can(regex("^(|)$", var.hana_scale_out_shared_storage_type))
    )
    error_message = "Invalid HANA scale out storage type. Options: none."
  }
}

# Monitoring related variables
variable "monitoring_name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "vmmonitoring"
}

variable "monitoring_network_domain" {
  description = "hostname's network domain"
  type        = string
  default     = ""
}

variable "monitoring_srv_ip" {
  description = "Monitoring server address"
  type        = string
  default     = ""
}

variable "monitoring_os_image" {
  description = "The image used to create the monitoring machines"
  type        = string
  default     = ""
}

variable "monitoring_flavor" {
  description = "The instance type of the monitoring machines"
  type        = string
  default     = "2C-2GB-40GB"
}

variable "monitoring_enabled" {
  description = "Enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

# SBD related variables
# In order to enable SBD, an ISCSI server is needed as right now is the unique option
# All the clusters will use the same mechanism

variable "sbd_storage_type" {
  description = "Choose the SBD storage type. Options: iscsi"
  type        = string
  default     = "iscsi"
}

# If iscsi is selected as sbd_storage_type
# Use the next variables for advanced configuration

variable "iscsi_name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "vmiscsi"
}

variable "iscsi_network_domain" {
  description = "hostname's network domain"
  type        = string
  default     = ""
}

variable "iscsi_os_image" {
  description = "The image used to create the iscsi machines"
  type        = string
  default     = ""
}

variable "iscsi_flavor" {
  description = "The instance type of the iscsi nodes"
  type        = string
  default     = "2C-2GB-40GB"
}

variable "iscsi_srv_ip" {
  description = "IP for iSCSI server. It must be in the same network addresses range defined in `ip_cidr_range`"
  type        = string
  default     = ""
}

variable "iscsi_lun_count" {
  description = "Number of LUN (logical units) to serve with the iscsi server. Each LUN can be used as a unique sbd disk"
  default     = 3
}

variable "iscsi_disk_size" {
  description = "Disk size in GB used to create the LUNs and partitions to be served by the ISCSI service"
  type        = number
  default     = 10
}

# DRBD related variables

variable "drbd_name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "vmdrbd"
}

variable "drbd_network_domain" {
  description = "hostname's network domain"
  type        = string
  default     = ""
}

variable "drbd_enabled" {
  description = "Enable the DRBD cluster for nfs"
  type        = bool
  default     = false
}

variable "drbd_flavor" {
  description = "The instance type of the drbd nodes"
  type        = string
  default     = "2C-2GB-40GB"
}

variable "drbd_os_image" {
  description = "The image used to create the drbd machines"
  type        = string
  default     = ""
}

variable "drbd_data_disk_size" {
  description = "Disk size of the disks used to store drbd content"
  type        = string
  default     = "10"
}

variable "drbd_data_disk_type" {
  description = "Disk type of the disks used to store drbd content"
  type        = string
  default     = "pd-standard"
}

variable "drbd_ips" {
  description = "ip addresses to set to the drbd cluster nodes. They must be in the same network addresses range defined in `ip_cidr_range`"
  type        = list(string)
  default     = []
}

variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP. It must be in other subnet than the machines!"
  type        = string
  default     = ""
}

variable "drbd_cluster_fencing_mechanism" {
  description = "Select the DRBD cluster fencing mechanism. Options: sbd, native"
  type        = string
  default     = "sbd"
}

variable "drbd_nfs_mounting_point" {
  description = "Mounting point of the NFS share created in to of DRBD (`/mnt` must not be used in Azure)"
  type        = string
  default     = "/mnt_permanent/sapdata"
}

# Netweaver related variables

variable "netweaver_name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "vmnetweaver"
}

variable "netweaver_network_domain" {
  description = "hostname's network domain"
  type        = string
  default     = ""
}

variable "netweaver_enabled" {
  description = "Enable netweaver cluster creation"
  type        = bool
  default     = false
}

variable "netweaver_app_server_count" {
  description = "Number of PAS/AAS servers (1 PAS and the rest will be AAS). 0 means that the PAS is installed in the same machines as the ASCS"
  type        = number
  default     = 2
}

variable "netweaver_flavor" {
  description = "The instance type of the netweaver nodes"
  type        = string
  default     = "2C-2GB-40GB"
}

variable "netweaver_os_image" {
  description = "The image used to create the netweaver machines"
  type        = string
  default     = ""
}

variable "netweaver_software_bucket" {
  description = "GCP storage bucket that contains the netweaver installation files"
  type        = string
  default     = ""
}

variable "netweaver_ips" {
  description = "ip addresses to set to the netweaver cluster nodes. They must be in the same network addresses range defined in `ip_cidr_range`"
  type        = list(string)
  default     = []
}

variable "netweaver_virtual_ips" {
  description = "virtual ip addresses to set to the nodes. The first 2 nodes will be part of the HA cluster so they addresses must be outside of the subnet mask"
  type        = list(string)
  default     = []
}

variable "netweaver_sid" {
  description = "System identifier of the Netweaver installation (e.g.: HA1 or PRD)"
  type        = string
  default     = "HA1"
}

variable "netweaver_ascs_instance_number" {
  description = "Instance number of the ASCS system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "00"
}

variable "netweaver_ers_instance_number" {
  description = "Instance number of the ERS system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "10"
}

variable "netweaver_pas_instance_number" {
  description = "Instance number of the PAS system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "01"
}

variable "netweaver_master_password" {
  description = "Master password for the Netweaver system (sidadm user included)"
  type        = string
  default     = ""
}

variable "netweaver_cluster_fencing_mechanism" {
  description = "Select the Netweaver cluster fencing mechanism. Options: sbd, native"
  type        = string
  default     = "sbd"
}

variable "netweaver_nfs_share" {
  description = "URL of the NFS share where /sapmnt and /usr/sap/{sid}/SYS will be mounted. This folder must have the sapmnt and usrsapsys folders. This parameter can be omitted if drbd_enabled is set to true, as a HA nfs share will be deployed by the project. Finally, if it is not used or set empty, these folders are created locally (for single machine deployments)"
  type        = string
  default     = ""
}

variable "netweaver_sapmnt_path" {
  description = "Path where sapmnt folder is stored"
  type        = string
  default     = "/sapmnt"
}

variable "netweaver_product_id" {
  description = "Netweaver installation product. Even though the module is about Netweaver, it can be used to install other SAP instances like S4/HANA"
  type        = string
  default     = "NW750.HDB.ABAPHA"
}

variable "netweaver_inst_media" {
  description = "URL of the NFS share where the SAP Netweaver software installer is stored. This media shall be mounted in `netweaver_inst_folder`"
  type        = string
  default     = ""
}

variable "netweaver_inst_folder" {
  description = "Folder where SAP Netweaver installation files are mounted"
  type        = string
  default     = "/sapmedia/NW"
}

variable "netweaver_extract_dir" {
  description = "Extraction path for Netweaver media archives of SWPM and netweaver additional dvds"
  type        = string
  default     = "/sapmedia_extract/NW"
}

variable "netweaver_swpm_folder" {
  description = "Netweaver software SWPM folder, path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_sapcar_exe" {
  description = "Path to sapcar executable, relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_swpm_sar" {
  description = "SWPM installer sar archive containing the installer, path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_sapexe_folder" {
  description = "Software folder where needed sapexe `SAR` executables are stored (sapexe, sapexedb, saphostagent), path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_additional_dvds" {
  description = "Software folder with additional SAP software needed to install netweaver (NW export folder and HANA HDB client for example), path relative from the `netweaver_inst_media` mounted point"
  type        = list
  default     = []
}

variable "netweaver_ha_enabled" {
  description = "Enable HA cluster in top of Netweaver ASCS and ERS instances"
  type        = bool
  default     = true
}

variable "netweaver_shared_storage_type" {
  description = "shared Storage type to use for Netweaver deployment - not supported yet for this cloud provider yet"
  type        = string
  default     = ""
  validation {
    condition = (
      can(regex("^(|)$", var.netweaver_shared_storage_type))
    )
    error_message = "Invalid Netweaver shared storage type. Options: none."
  }
}

# Specific QA variables

variable "qa_mode" {
  description = "Enable test/qa mode (disable extra packages usage not coming in the image)"
  type        = bool
  default     = false
}

variable "hwcct" {
  description = "Execute HANA Hardware Configuration Check Tool to bench filesystems"
  type        = bool
  default     = false
}

# Pre deployment

variable "pre_deployment" {
  description = "Enable pre deployment local execution. Only available for clients running Linux"
  type        = bool
  default     = false
}
