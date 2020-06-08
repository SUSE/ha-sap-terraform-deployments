data "azurerm_public_ip" "bastion" {
  count               = var.bastion_enabled ? 1 : 0
  name                = azurerm_public_ip.bastion[0].name
  resource_group_name = azurerm_virtual_machine.bastion[0].resource_group_name
}

output "public_ip" {
  value = join("", data.azurerm_public_ip.bastion.*.ip_address)
}
