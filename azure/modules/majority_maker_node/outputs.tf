data "azurerm_public_ip" "majority_maker" {
  count               = local.bastion_enabled ? 0 : var.node_count
  name                = element(azurerm_public_ip.majority_maker.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.majority_maker.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on = [azurerm_virtual_machine.majority_maker]
}

data "azurerm_network_interface" "majority_maker" {
  count               = var.node_count
  name                = element(azurerm_network_interface.majority_maker.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.majority_maker.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on = [azurerm_virtual_machine.majority_maker]
}

output "hana_ip" {
  value = [data.azurerm_network_interface.majority_maker.*.private_ip_address]
}

output "hana_public_ip" {
  value = [data.azurerm_public_ip.majority_maker.*.ip_address]
}

output "hana_name" {
  value = [azurerm_virtual_machine.majority_maker.*.name]
}

output "hana_public_name" {
  value = [data.azurerm_public_ip.majority_maker.*.fqdn]
}
