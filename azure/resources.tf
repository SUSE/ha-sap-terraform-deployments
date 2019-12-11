resource "azurerm_resource_group" "myrg" {
  name     = "rg-ha-sap-${terraform.workspace}"
  location = var.az_region
}

resource "azurerm_storage_account" "mytfstorageacc" {
  name                     = "stdiag${lower(terraform.workspace)}"
  resource_group_name      = azurerm_resource_group.myrg.name
  location                 = var.az_region
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    workspace = terraform.workspace
  }
}

