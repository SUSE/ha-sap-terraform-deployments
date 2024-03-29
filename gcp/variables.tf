# GCP related variables

variable "project" {
  description = "GCP project name where the infrastructure will be created"
  type        = string
}

variable "region" {
  description = "GCP region where the deployment machines will be created"
  type        = string
}

variable "gcp_credentials_file" {
  description = "GCP credentials file path in local machine"
  type        = string
}

variable "vpc_name" {
  description = "Already existing vpc name used by the created infrastructure. If it's not set a new one will be created"
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "Already existing subnet name used by the created infrastructure. If it's not set a new one will be created"
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
  validation {
    condition = (
      can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.ip_cidr_range))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
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

variable "admin_user" {
  description = "User used to connect to machines and bastion"
  type        = string
  default     = "root"
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

variable "bastion_os_image" {
  description = "sles4sap image used to create the bastion machines. Composed by 'Publisher:Offer:Sku:Version' syntax. Example: SUSE:sles-sap-15-sp4:gen2:latest"
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

variable "bastion_nat_min_ports_per_vm" {
  description = "Minimum ports per VM instance for the NAT router. Decreasing this value can compromise the deployment and make it fail"
  type        = number
  default     = 1024
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
  default     = "suse-sap-cloud/sles-15-sp4-sap"
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
  default     = "https://download.opensuse.org/repositories/network:ha-clustering:sap-deployments:v9"
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

variable "machine_type" {
  description = "The instance type of the hana nodes"
  type        = string
  default     = "n1-highmem-32"
}

variable "machine_type_majority_maker" {
  description = "The instance type of the hana majority_maker"
  type        = string
  default     = "n1-standard-4"
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
  validation {
    condition = (
      can([for v in var.hana_ips : regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", v)])
    )
    error_message = "Invalid IP address format."
  }
}

variable "hana_majority_maker_ip" {
  description = "ip address to set to the HANA Majority Maker node. If it's not set the addresses will be auto generated from the provided vnet address range"
  type        = string
  default     = ""
  validation {
    condition = (
      var.hana_majority_maker_ip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.hana_majority_maker_ip))
    )
    error_message = "Invalid IP address format."
  }
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

variable "hana_data_disks_configuration" {
  type = map(any)
  default = {
    disks_type = "pd-ssd,pd-ssd,pd-ssd,pd-ssd,pd-ssd,pd-ssd,pd-ssd"
    disks_size = "128,128,128,128,64,64,128"
    # The next variables are used during the provisioning
    luns     = "0,1#2,3#4#5#6"
    names    = "data#log#shared#usrsap#backup"
    lv_sizes = "100#100#100#100#100"
    paths    = "/hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup"
  }
  description = <<EOF
    This map describes how the disks will be formatted to create the definitive configuration during the provisioning.

    disks_type and disks_size are used during the disks creation. The number of elements must match in all of them
    "," is used to separate each disk.

    disk_type = The disk type used to create disks. See https://cloud.google.com/compute/docs/disks and https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk for reference.
    disk_size = The disk size in GB.

    luns, names, lv_sizes and paths are used during the provisioning to create/format/mount logical volumes and filesystems.
    "#" character is used to split the volume groups, while "," is used to define the logical volumes for each group
    The number of groups split by "#" must match in all of the entries.

    luns  -> The luns or disks used for each volume group. The number of luns must match with the configured in the previous disks variables (example 0,1#2,3#4#5#6)
    names -> The names of the volume groups and logical volumes (example data#log#shared#usrsap#backup)
    lv_sizes -> The size in % (from available space) dedicated for each logical volume and folder (example 50#50#100#100#100)
    paths -> Folder where each volume group will be mounted (example /hana/data,/hana/log#/hana/shared#/usr/sap#/hana/backup#/sapmnt/)
  EOF
}

variable "hana_fstype" {
  description = "Filesystem type used by the disk where hana is installed"
  type        = string
  default     = "xfs"
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

variable "hana_cluster_vip_mechanism" {
  description = "Mechanism used to manage the virtual IP address in the hana cluster. Options: load-balancer, route"
  type        = string
  default     = "load-balancer"
  validation {
    condition = (
      can(regex("^(load-balancer|route)$", var.hana_cluster_vip_mechanism))
    )
    error_message = "Invalid HANA cluster vip mechanism. Options: load-balancer|route ."
  }
}

variable "hana_cluster_vip" {
  description = "IP address used to configure the hana cluster floating IP. It must be in other subnet than the machines!"
  type        = string
  default     = ""
  validation {
    condition = (
      var.hana_cluster_vip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.hana_cluster_vip))
    )
    error_message = "Invalid IP address format."
  }
}

variable "hana_cluster_fencing_mechanism" {
  description = "Select the HANA cluster fencing mechanism. Options: sbd, native"
  type        = string
  default     = "native"
  validation {
    condition = (
      can(regex("^(sbd|native)$", var.hana_cluster_fencing_mechanism))
    )
    error_message = "Invalid HANA cluster fencing mechanism. Options: sbd|native ."
  }
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
  validation {
    condition = (
      var.hana_cluster_vip_secondary == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.hana_cluster_vip_secondary))
    )
    error_message = "Invalid IP address format."
  }
}

variable "hana_extra_parameters" {
  type        = map(any)
  default     = {}
  description = <<EOF
    This map allows to add any extra parameters to the HANA installation (inside the installation configfile).
    For more details about the parameters, have a look at the Parameter Reference, e.g.
    https://help.sap.com/docs/SAP_HANA_PLATFORM/2c1988d620e04368aa4103bf26f17727/c16432a77b6144dcb75aace2b4fcacff.html

    Some examples:
    hana_extra_parameters = {
      ignore = "check_min_mem",
      install_execution_mode = "optimized"
    }
  EOF
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
      can(regex("^(|filestore)$", var.hana_scale_out_shared_storage_type))
    )
    error_message = "Invalid HANA scale out storage type. Options: filestore."
  }
}

variable "hana_scale_out_addhosts" {
  type        = map(any)
  default     = {}
  description = <<EOF
    Additional hosts to pass to HANA scale-out installation
  EOF
}

variable "hana_scale_out_standby_count" {
  description = "Number of HANA scale-out standby nodes to be deployed per site."
  type        = number
  default     = "0"
}

variable "hana_ha_dr_sustkover_enabled" {
  description = "enable susTkOver hook"
  type        = bool
  default     = false
}

variable "hana_ha_dr_suschksrv_enabled" {
  description = "enable susChkSrv hook"
  type        = bool
  default     = false
}

variable "hana_ha_dr_suschksrv_action_on_lost" {
  description = "define action on lost for susChkSrv, see `man 7 susChkSrv.py`"
  type        = string
  default     = "stop"
}

variable "filestore_tier" {
  description = "service level / tier for filestore shared Storage"
  type        = string
  default     = "BASIC_SSD"
  validation {
    condition = (
      can(regex("^(BASIC_SSD|ENTERPRISE)$", var.filestore_tier))
    )
    error_message = "Invalid filestore Pool service level. Options: BASIC_SSD|ENTERPRISE."
  }
}

variable "netweaver_filestore_quota_sapmnt" {
  description = "Quota for filestore shared storage volume Netweaver"
  type        = number
  default     = "1024"
}

variable "hana_scale_out_filestore_quota_data" {
  description = "Quota for filestore shared storage volume HANA scale-out data"
  type        = number
  default     = "1024"
}

variable "hana_scale_out_filestore_quota_log" {
  description = "Quota for filestore shared storage volume HANA scale-out log"
  type        = number
  default     = "1024"
}

variable "hana_scale_out_filestore_quota_backup" {
  description = "Quota for filestore shared storage volume HANA scale-out backup"
  type        = number
  default     = "1024"
}

variable "hana_scale_out_filestore_quota_shared" {
  description = "Quota for filestore shared storage volume HANA scale-out shared"
  type        = number
  default     = "1024"
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
  validation {
    condition = (
      var.monitoring_srv_ip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.monitoring_srv_ip))
    )
    error_message = "Invalid IP address format."
  }
}

variable "monitoring_os_image" {
  description = "The image used to create the monitoring machines"
  type        = string
  default     = ""
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
  validation {
    condition = (
      can(regex("^(iscsi)$", var.sbd_storage_type))
    )
    error_message = "Invalid SBD storage type. Options: iscsi ."
  }
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

variable "machine_type_iscsi_server" {
  description = "The instance type of the iscsi nodes"
  type        = string
  default     = "custom-1-2048"
}

variable "iscsi_srv_ip" {
  description = "IP for iSCSI server. It must be in the same network addresses range defined in `ip_cidr_range`"
  type        = string
  default     = ""
  validation {
    condition = (
      var.iscsi_srv_ip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.iscsi_srv_ip))
    )
    error_message = "Invalid IP address format."
  }
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

variable "drbd_machine_type" {
  description = "The instance type of the drbd nodes"
  type        = string
  default     = "n1-standard-4"
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
  validation {
    condition = (
      can([for v in var.drbd_ips : regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", v)])
    )
    error_message = "Invalid IP address format."
  }
}

variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP. It must be in other subnet than the machines!"
  type        = string
  default     = ""
  validation {
    condition = (
      var.drbd_cluster_vip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.drbd_cluster_vip))
    )
    error_message = "Invalid IP address format."
  }
}

variable "drbd_cluster_fencing_mechanism" {
  description = "Select the DRBD cluster fencing mechanism. Options: sbd, native"
  type        = string
  default     = "native"
  validation {
    condition = (
      can(regex("^(sbd|native)$", var.drbd_cluster_fencing_mechanism))
    )
    error_message = "Invalid DRBD cluster fencing mechanism. Options: sbd|native ."
  }
}

variable "drbd_cluster_vip_mechanism" {
  description = "Mechanism used to manage the virtual IP address in the drbd cluster. Options: load-balancer, route"
  type        = string
  default     = "load-balancer"
  validation {
    condition = (
      can(regex("^(load-balancer|route)$", var.drbd_cluster_vip_mechanism))
    )
    error_message = "Invalid DRBD cluster vip mechanism. Options: load-balancer|route ."
  }
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

variable "netweaver_machine_type" {
  description = "The instance type of the netweaver nodes"
  type        = string
  default     = "n1-highmem-8"
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
  validation {
    condition = (
      can([for v in var.netweaver_ips : regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", v)])
    )
    error_message = "Invalid IP address format."
  }
}

variable "netweaver_virtual_ips" {
  description = "virtual ip addresses to set to the nodes. The first 2 nodes will be part of the HA cluster so they addresses must be outside of the subnet mask"
  type        = list(string)
  default     = []
  validation {
    condition = (
      can([for v in var.netweaver_virtual_ips : regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", v)])
    )
    error_message = "Invalid IP address format."
  }
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
  default     = "native"
  validation {
    condition = (
      can(regex("^(native|sbd)$", var.netweaver_cluster_fencing_mechanism))
    )
    error_message = "Invalid Netweaver cluster fending mechanism. Options: native|sbd ."
  }
}

variable "netweaver_cluster_vip_mechanism" {
  description = "Mechanism used to manage the virtual IP address in the netweaver cluster. Options: load-balancer, route"
  type        = string
  default     = "load-balancer"
  validation {
    condition = (
      can(regex("^(load-balancer|route)$", var.netweaver_cluster_vip_mechanism))
    )
    error_message = "Invalid Netweaver cluster vip mechanism. Options: load-balancer|route ."
  }
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
  type        = list(any)
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
  default     = "drbd"
  validation {
    condition = (
      can(regex("^(drbd|filestore)$", var.netweaver_shared_storage_type))
    )
    error_message = "Invalid Netweaver shared storage type. Options: drbd|filestore."
  }
}

# Testing and QA variables

# Disable extra package installation (sap, ha pattern etc).
# Disables first registration to install salt-minion, it is considered that images are delivered with salt-minion
variable "offline_mode" {
  description = "Disable installation of extra packages usage not coming with image"
  type        = bool
  default     = false
}

# Execute HANA Hardware Configuration Check Tool to bench filesystems.
# The test takes several hours. See results in /root/hwcct_out and in global log file /var/log/salt-result.log.
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

#
# Post deployment
#
variable "cleanup_secrets" {
  description = "Enable salt states that cleanup secrets, e.g. delete /etc/salt/grains"
  type        = bool
  default     = false
}
