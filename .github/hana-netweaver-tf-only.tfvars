hana_inst_media     = "10.162.32.134:/sapdata/sap_inst_media/51053787"
iprange             = "192.168.16.0/24"

storage_pool = "terraform"

# Enable pre deployment to automatically copy the pillar files and create cluster ssh keys
pre_deployment = true

# For iscsi, it will deploy a new machine hosting an iscsi service
shared_storage_type = "shared-disk"
ha_sap_deployment_repo = "https://download.opensuse.org/repositories/network:/ha-clustering:/sap-deployments:/devel"

monitoring_enabled = true

# don't use salt for this test
provisioner = ""

# Netweaver variables

# Enable/disable Netweaver deployment
netweaver_enabled = true

# NFS share with netweaver installation folders
netweaver_inst_media     = "10.162.32.134:/sapdata/sap_inst_media"
netweaver_swpm_folder     =  "SWPM_10_SP26_6"

# Install NetWeaver
netweaver_sapexe_folder   =  "kernel_nw75_sar"
netweaver_additional_dvds = ["51050829_3", "51053787"]


# NFS share to store the Netweaver shared files
netweaver_nfs_share    = "192.168.108.201:/HA1"

# DRBD variables

# Enable the DRBD cluster for nfs
drbd_enabled = true

# IP of DRBD cluster
drbd_shared_storage_type = "shared-disk"

devel_mode = false
