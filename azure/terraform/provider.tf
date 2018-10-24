# Configure the Azure Provider
provider "azurerm" {
  version         = "~> 1.13"
  subscription_id = "<subscription id>"
  client_id       = "<app id>"
  client_secret   = "<client secret>"
  tenant_id       = "<tenand id>"
}

provider "template" {
  version = "~> 1.0"
}
