# Store Terraform state in Azure Storage

Please read the (Microsoft documentation how to store terraform state in azure storage)[https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage] to get a general understanding about remote state.

## Example implementation

- You might want to use `create_remote_state/create_container.sh` (change variables first) to create:
  - resource group
  - storage account
  - stroage container

- Copy `remote_state/credentials.tfvars.example` to `remote_state/credentials.tfvars` and change the variables.
  - Lookup your "key1" in the storage account "Access keys" tab and use it as "key".

- Add this block to `infrastructure.tf`
```
terraform {
  backend "azurerm" {}
}
```

- Initialize the remote state by run `terraform init -backend-config=create_remote_state/credentials.tfvars`.
