data "azurerm_public_ip" "netweaver" {
  count               = local.bastion_enabled ? 0 : local.vm_count
  name                = element(azurerm_public_ip.netweaver.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.netweaver.*.resource_group_name, count.index)
}

data "azurerm_network_interface" "netweaver" {
  count               = local.vm_count
  name                = element(azurerm_network_interface.netweaver.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.netweaver.*.resource_group_name, count.index)
}

output "netweaver_ip" {
  value = data.azurerm_network_interface.netweaver.*.private_ip_address
}

output "netweaver_public_ip" {
  value = data.azurerm_public_ip.netweaver.*.ip_address
}

output "netweaver_name" {
  value = azurerm_virtual_machine.netweaver.*.name
}

output "netweaver_public_name" {
  value = data.azurerm_public_ip.netweaver.*.fqdn
}
