# This configuration defines the custom image to use

# Variable for the image URI. Run as terraform apply -var image_uri https://blob.azure.microsoft.com/this/is/my/image.vhd

variable "image_uri" {
  type = "string"
}

variable "image_uri_iscsi_srv" {
  type = "string"
}

resource "azurerm_image" "custom" {
  name                = "BVSles4SapImg"
  location            = "${var.az_region}"
  resource_group_name = "${azurerm_resource_group.myrg.name}"

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = "${var.image_uri}"
    size_gb  = "32"
  }

  tags {
    workspace = "${terraform.workspace}"
  }
}

resource "azurerm_image" "custom_iscsi" {
  name                = "BVSles4SapImgIscsi"
  location            = "${var.az_region}"
  resource_group_name = "${azurerm_resource_group.myrg.name}"
  count               = "${var.image_uri_iscsi_srv != "" ? 1 : 0}"

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = "${var.image_uri_iscsi_srv}"
    size_gb  = "32"
  }

  tags {
    workspace = "${terraform.workspace}"
  }
}
