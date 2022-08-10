data "azurerm_public_ip" "hana" {
  count               = local.bastion_enabled ? 0 : var.hana_count
  name                = element(azurerm_public_ip.hana.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.hana.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on = [azurerm_virtual_machine.hana]
}

data "azurerm_network_interface" "hana" {
  count               = var.hana_count
  name                = element(azurerm_network_interface.hana.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.hana.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on = [azurerm_virtual_machine.hana]
}

output "hana_ip" {
  value = [data.azurerm_network_interface.hana.*.private_ip_address]
}

output "hana_public_ip" {
  value = [data.azurerm_public_ip.hana.*.ip_address]
}

output "hana_name" {
  value = [azurerm_virtual_machine.hana.*.name]
}

output "hana_public_name" {
  value = [data.azurerm_public_ip.hana.*.fqdn]
}
