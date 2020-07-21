# the following 2 vars are aquired via ENV
# qemu_uri            =
# source_image        =

hana_inst_media     = "10.162.32.134:/sapdata/sap_inst_media/51053787"
iprange             = "192.168.25.0/24"

storage_pool = "terraform"

# Enable pre deployment to automatically copy the pillar files and create cluster ssh keys
pre_deployment = true

# For iscsi, it will deploy a new machine hosting an iscsi service
sbd_storage_type = "iscsi"
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


# DRBD variables

# Enable the DRBD cluster for nfs
drbd_enabled = true
