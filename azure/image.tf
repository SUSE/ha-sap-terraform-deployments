# This configuration defines the custom image to use

# Variable for the image URI. Run as terraform apply -var sles4sap_uri https://blob.azure.microsoft.com/this/is/my/image.vhd
# If custom uris are enabled public information will be omitted
# One of the two options must be used

variable "sles4sap_uri" {
  type    = string
  default = ""
}

variable "hana_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "hana_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "hana_public_sku" {
  type    = string
  default = "12-sp4"
}

variable "hana_public_version" {
  type    = string
  default = "latest"
}

variable "iscsi_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "iscsi_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "iscsi_public_sku" {
  type    = string
  default = "15"
}

variable "iscsi_public_version" {
  type    = string
  default = "latest"
}

variable "iscsi_srv_uri" {
  type    = string
  default = ""
}

variable "monitoring_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "monitoring_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "monitoring_public_sku" {
  type    = string
  default = "15"
}

variable "monitoring_public_version" {
  type    = string
  default = "latest"
}

variable "monitoring_uri" {
  type    = string
  default = ""
}

variable "drbd_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "drbd_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "drbd_public_sku" {
  type    = string
  default = "15"
}

variable "drbd_public_version" {
  type    = string
  default = "latest"
}

variable "drbd_image_uri" {
  type    = string
  default = ""
}

variable "netweaver_public_publisher" {
  type    = string
  default = "SUSE"
}

variable "netweaver_public_offer" {
  type    = string
  default = "SLES-SAP-BYOS"
}

variable "netweaver_public_sku" {
  type    = string
  default = "15"
}

variable "netweaver_public_version" {
  type    = string
  default = "latest"
}

variable "netweaver_image_uri" {
  type    = string
  default = ""
}

resource "azurerm_image" "sles4sap" {
  count               = var.sles4sap_uri != "" ? 1 : 0
  name                = "BVSles4SapImg"
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.sles4sap_uri
    size_gb  = "32"
  }

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_image" "iscsi_srv" {
  count               = var.iscsi_srv_uri != "" ? 1 : 0
  name                = "IscsiSrvImg"
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.iscsi_srv_uri
    size_gb  = "32"
  }

  tags = {
    workspace = terraform.workspace
  }
}

