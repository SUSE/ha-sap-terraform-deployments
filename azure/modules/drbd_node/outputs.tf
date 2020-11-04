data "azurerm_public_ip" "drbd" {
  count               = local.bastion_enabled ? 0 : var.drbd_count
  name                = element(azurerm_public_ip.drbd.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.drbd.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on          = [azurerm_virtual_machine.drbd]
}

data "azurerm_network_interface" "drbd" {
  count               = var.drbd_count
  name                = element(azurerm_network_interface.drbd.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.drbd.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on          = [azurerm_virtual_machine.drbd]
}

output "drbd_ip" {
  value = data.azurerm_network_interface.drbd.*.private_ip_address
}

output "drbd_public_ip" {
  value = data.azurerm_public_ip.drbd.*.ip_address
}

output "drbd_name" {
  value = azurerm_virtual_machine.drbd.*.name
}

output "drbd_public_name" {
  value = data.azurerm_public_ip.drbd.*.fqdn
}
