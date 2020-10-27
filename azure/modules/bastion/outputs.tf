data "azurerm_public_ip" "bastion" {
  count               = local.bastion_enabled
  name                = azurerm_public_ip.bastion[0].name
  resource_group_name = azurerm_virtual_machine.bastion[0].resource_group_name
}

output "public_ip" {
  value = join("", data.azurerm_public_ip.bastion.*.ip_address)
}
