# Configure the Azure Provider
provider "azurerm" {
  version = "<= 1.33"
}

provider "template" {
  version = "~> 2.1"
}

terraform {
  required_version = ">= 0.12"
}
