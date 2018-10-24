terraform {
  backend "azurerm" {
    storage_account_name = "tfstate7981"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "state-demo-secure" {
  name     = "state-demo"
  location = "westeurope"
}
