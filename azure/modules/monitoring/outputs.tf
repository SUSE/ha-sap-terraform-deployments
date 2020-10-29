data "azurerm_public_ip" "monitoring" {
  count               = local.bastion_enabled == false && var.monitoring_enabled == true ? 1 : 0
  name                = azurerm_public_ip.monitoring.0.name
  resource_group_name = azurerm_virtual_machine.monitoring.0.resource_group_name
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on          = [azurerm_virtual_machine.monitoring]
}

data "azurerm_network_interface" "monitoring" {
  count               = var.monitoring_enabled == true ? 1 : 0
  name                = azurerm_network_interface.monitoring.0.name
  resource_group_name = azurerm_virtual_machine.monitoring.0.resource_group_name
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on          = [azurerm_virtual_machine.monitoring]
}

output "monitoring_ip" {
  value = join("", data.azurerm_network_interface.monitoring.*.private_ip_address)
}

output "monitoring_public_ip" {
  value = join("", data.azurerm_public_ip.monitoring.*.ip_address)
}

output "monitoring_name" {
  value = join("", azurerm_virtual_machine.monitoring.*.name)
}

output "monitoring_public_name" {
  value = join("", data.azurerm_public_ip.monitoring.*.fqdn)
}
