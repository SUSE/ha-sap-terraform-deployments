# This configuration defines the custom image to use

# Variable for the image URI. Run as terraform apply -var sles4sap_uri https://blob.azure.microsoft.com/this/is/my/image.vhd
# If custom uris are enabled public information will be omitted
# One of the two options must be used

variable "sles4sap_uri" {
  type    = "string"
  default = ""
}

variable "sles4sap_public" {
  type = "map"

  default = {
    "publisher" = "SUSE"
    "offer"     = "SLES-SAP-BYOS"
    "sku"       = "12-sp4"
    "version"   = "2019.03.06"
  }
}

variable "iscsi_srv_uri" {
  type    = "string"
  default = ""
}

variable "iscsi_srv_public" {
  type = "map"

  default = {
    "publisher" = "SUSE"
    "offer"     = "SLES-SAP-BYOS"
    "sku"       = "15"
    "version"   = "2018.08.20"
  }
}

resource "azurerm_image" "sles4sap" {
  count               = "${var.sles4sap_uri != "" ? 1 : 0}"
  name                = "BVSles4SapImg"
  location            = "${var.az_region}"
  resource_group_name = "${azurerm_resource_group.myrg.name}"

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = "${var.sles4sap_uri}"
    size_gb  = "32"
  }

  tags {
    workspace = "${terraform.workspace}"
  }
}

resource "azurerm_image" "iscsi_srv" {
  count               = "${var.iscsi_srv_uri != "" ? 1 : 0}"
  name                = "IscsiSrvImg"
  location            = "${var.az_region}"
  resource_group_name = "${azurerm_resource_group.myrg.name}"

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = "${var.iscsi_srv_uri}"
    size_gb  = "16"
  }

  tags {
    workspace = "${terraform.workspace}"
  }
}
