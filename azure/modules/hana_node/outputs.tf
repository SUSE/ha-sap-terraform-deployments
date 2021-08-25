data "azurerm_public_ip" "hana" {
  count               = local.bastion_enabled ? 0 : var.hana_count
  name                = element(azurerm_public_ip.hana.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.hana.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on = [azurerm_virtual_machine.hana]
}

data "azurerm_public_ip" "mm" {
  count               = local.bastion_enabled ? 0 : local.create_scale_out
  name                = element(azurerm_public_ip.mm.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.mm.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on          = [azurerm_virtual_machine.mm]
}

data "azurerm_network_interface" "hana" {
  count               = var.hana_count
  name                = element(azurerm_network_interface.hana.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.hana.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on = [azurerm_virtual_machine.hana]
}

data "azurerm_network_interface" "mm" {
  count               = local.create_scale_out
  name                = element(azurerm_network_interface.mm.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.mm.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on          = [azurerm_virtual_machine.mm]
}

output "cluster_nodes_ip" {
  value = [data.azurerm_network_interface.hana.*.private_ip_address, data.azurerm_network_interface.mm.*.private_ip_address]
}

output "cluster_nodes_public_ip" {
  value = [data.azurerm_public_ip.hana.*.ip_address, data.azurerm_public_ip.mm.*.ip_address]
}

output "cluster_nodes_name" {
  value = [azurerm_virtual_machine.hana.*.name, azurerm_virtual_machine.mm.*.name]
}

output "cluster_nodes_public_name" {
  value = [data.azurerm_public_ip.hana.*.fqdn, data.azurerm_public_ip.mm.*.fqdn]
}
