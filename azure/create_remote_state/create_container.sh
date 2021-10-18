#!/usr/bin/env bash

LOCATION=westeurope
RESOURCE_GROUP_NAME=fortinet0
STORAGE_ACCOUNT_NAME="${RESOURCE_GROUP_NAME}tfstate${RANDOM}"
CONTAINER_NAME=tfstate

# Create resource group
az group create --name "${RESOURCE_GROUP_NAME}" --location "${LOCATION}"

# Create storage account
az storage account create --resource-group "${RESOURCE_GROUP_NAME}" --name "${STORAGE_ACCOUNT_NAME}" --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name "${CONTAINER_NAME}" --account-name "${STORAGE_ACCOUNT_NAME}"
