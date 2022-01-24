output "subnet-hub-external-fgt" {
  value = azurerm_subnet.subnet-hub-external-fgt
}

output "subnet-hub-external-fgt-address-range" {
  value = local.subnet_external_fgt_address_range
}

output "subnet-hub-internal-fgt" {
  value = azurerm_subnet.subnet-hub-internal-fgt
}

output "subnet-hub-internal-fgt-address-range" {
  value = local.subnet_internal_fgt_address_range
}

output "subnet-hub-hasync-ftnt" {
  value = azurerm_subnet.subnet-hub-hasync-ftnt
}

output "subnet-hub-hasync-ftnt-address-range" {
  value = local.subnet_hasync_ftnt_address_range
}

output "subnet-hub-mgmt-ftnt" {
  value = azurerm_subnet.subnet-hub-mgmt-ftnt
}

output "subnet-hub-mgmt-ftnt-address-range" {
  value = local.subnet_mgmt_ftnt_address_range
}

output "subnet-hub-external-fadc" {
  value = azurerm_subnet.subnet-hub-external-fadc
}

output "subnet-hub-external-fadc-address-range" {
  value = local.subnet_external_fadc_address_range
}

output "subnet-hub-internal-fadc" {
  value = azurerm_subnet.subnet-hub-internal-fadc
}

output "subnet-hub-internal-fadc-address-range" {
  value = local.subnet_internal_fadc_address_range
}
