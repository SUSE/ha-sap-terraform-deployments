# Launch SLES-HAE of SLES4SAP cluster nodes

data "azurerm_public_ip" "monitoring" {
  count               = var.monitoring_enabled == true ? 1 : 0
  name                = element(azurerm_public_ip.monitoring.*.name, count.index)
  resource_group_name = element(
    azurerm_virtual_machine.monitoring.*.resource_group_name,
    count.index,
  )
}

output "monitoring_ip" {
  value = data.azurerm_public_ip.monitoring.*.ip_address
}

data "azurerm_public_ip" "iscsisrv" {
  name                = azurerm_public_ip.iscsisrv.name
  resource_group_name = azurerm_virtual_machine.iscsisrv.resource_group_name
}

output "iscsisrv_ip" {
  value = data.azurerm_public_ip.iscsisrv.ip_address
}

data "azurerm_public_ip" "clusternodes" {
  count               = var.ninstances
  name                = element(azurerm_public_ip.clusternodes.*.name, count.index)
  resource_group_name = element(
    azurerm_virtual_machine.clusternodes.*.resource_group_name,
    count.index,
  )
}

output "cluster_nodes_ip" {
  value = data.azurerm_public_ip.clusternodes.*.ip_address
}
