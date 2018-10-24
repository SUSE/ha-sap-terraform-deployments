#!/bin/bash -e
# Adapted from https://docs.microsoft.com/en-us/azure/terraform/terraform-backend

RESOURCE_GROUP_NAME=tfstate
# Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate

LOCATION="westeurope"

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "Creating remote-state.tf" 1>&2

cat > remote-state.tf << EOF
terraform {
  backend "azurerm" {
    storage_account_name = "$STORAGE_ACCOUNT_NAME"
    container_name       = "$CONTAINER_NAME"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "my-terraform-state" {
  name     = "my-terraform-state"
  location = "$LOCATION"
}
EOF

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"

echo "Run: export ARM_ACCESS_KEY=$ACCOUNT_KEY"
