resource "azurerm_resource_group" "myrg" {
  name     = "My-TF-Resources"
  location = "${var.az_region}"
}

resource "azurerm_storage_account" "mytfstorageacc" {
  name                     = "mytfstorageacc"
  resource_group_name      = "${azurerm_resource_group.myrg.name}"
  location                 = "${var.az_region}"
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags {
    environment = "Build Validation"
  }
}
