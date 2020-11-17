data "azurerm_public_ip" "bastion" {
  count               = local.bastion_count
  name                = azurerm_public_ip.bastion[0].name
  resource_group_name = azurerm_virtual_machine.bastion[0].resource_group_name
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on          = [azurerm_virtual_machine.bastion]
}

output "public_ip" {
  value = join("", data.azurerm_public_ip.bastion.*.ip_address)
}
