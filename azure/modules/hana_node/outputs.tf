data "azurerm_public_ip" "hana" {
  count = var.hana_count
  name  = element(azurerm_public_ip.hana.*.name, count.index)
  resource_group_name = element(
    azurerm_virtual_machine.hana.*.resource_group_name,
    count.index,
  )
}

data "azurerm_network_interface" "hana" {
  count = var.hana_count
  name  = element(azurerm_network_interface.hana.*.name, count.index)
  resource_group_name = element(
    azurerm_virtual_machine.hana.*.resource_group_name,
    count.index,
  )
}

output "cluster_nodes_ip" {
  value = data.azurerm_network_interface.hana.*.private_ip_address
}

output "cluster_nodes_public_ip" {
  value = data.azurerm_public_ip.hana.*.ip_address
}

output "cluster_nodes_name" {
  value = azurerm_virtual_machine.hana.*.name
}

output "cluster_nodes_public_name" {
  value = data.azurerm_public_ip.hana.*.fqdn
}

output "cluster_nodes_id" {
  value = azurerm_virtual_machine.hana.*.id
}
