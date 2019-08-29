# Launch SLES-HAE of SLES4SAP cluster nodes

data "azurerm_public_ip" "iscsisrv" {
  name                = azurerm_public_ip.iscsisrv.name
  resource_group_name = azurerm_virtual_machine.iscsisrv.resource_group_name
}

data "azurerm_public_ip" "monitoring" {
  name                = azurerm_public_ip.monitoring.name
  resource_group_name = azurerm_virtual_machine.monitoring.resource_group_name
}

data "azurerm_public_ip" "clusternodes" {
  count = var.ninstances
  name  = element(azurerm_public_ip.clusternodes.*.name, count.index)
  resource_group_name = element(
    azurerm_virtual_machine.clusternodes.*.resource_group_name,
    count.index,
  )
}

# Outputs: IP address and port where the service will be listening on

output "iscsisrv_ip" {
  value = data.azurerm_public_ip.iscsisrv.ip_address
}

output "monitoring_ip" {
  value = data.azurerm_public_ip.monitoring.ip_address
}

output "cluster_nodes_ip" {
  value = [data.azurerm_public_ip.clusternodes.*.ip_address]
}

