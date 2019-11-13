# Outputs:
# - Private IP
# - Public IP
# - Private node name
# - Public node name

# iSCSI server

data "azurerm_public_ip" "iscsisrv" {
  name                = azurerm_public_ip.iscsisrv.name
  resource_group_name = azurerm_virtual_machine.iscsisrv.resource_group_name
}

data "azurerm_network_interface" "iscsisrv" {
  name                = azurerm_network_interface.iscsisrv.name
  resource_group_name = azurerm_virtual_machine.iscsisrv.resource_group_name
}

output "iscsisrv_ip" {
  value = [data.azurerm_network_interface.iscsisrv.private_ip_address]
}

output "iscsisrv_public_ip" {
  value = [data.azurerm_public_ip.iscsisrv.ip_address]
}

output "iscsisrv_name" {
  value = [azurerm_virtual_machine.iscsisrv.name]
}

output "iscsisrv_public_name" {
  value = [data.azurerm_public_ip.iscsisrv.fqdn]
}

# Cluster nodes

data "azurerm_public_ip" "clusternodes" {
  count = var.ninstances
  name  = element(azurerm_public_ip.clusternodes.*.name, count.index)
  resource_group_name = element(
    azurerm_virtual_machine.clusternodes.*.resource_group_name,
    count.index,
  )
}

data "azurerm_network_interface" "clusternodes" {
  count = var.ninstances
  name  = element(azurerm_network_interface.clusternodes.*.name, count.index)
  resource_group_name = element(
    azurerm_virtual_machine.clusternodes.*.resource_group_name,
    count.index,
  )
}

output "cluster_nodes_ip" {
  value = data.azurerm_network_interface.clusternodes.*.private_ip_address
}

output "cluster_nodes_public_ip" {
  value = data.azurerm_public_ip.clusternodes.*.ip_address
}

output "cluster_nodes_name" {
  value = azurerm_virtual_machine.clusternodes.*.name
}

output "cluster_nodes_public_name" {
  value = data.azurerm_public_ip.clusternodes.*.fqdn
}

# Monitoring

data "azurerm_public_ip" "monitoring" {
  count = var.monitoring_enabled == true ? 1 : 0
  name  = azurerm_public_ip.monitoring.0.name
  resource_group_name = azurerm_virtual_machine.monitoring.0.resource_group_name
}

data "azurerm_network_interface" "monitoring" {
  count = var.monitoring_enabled == true ? 1 : 0
  name  = azurerm_network_interface.monitoring.0.name
  resource_group_name = azurerm_virtual_machine.monitoring.0.resource_group_name
}

output "monitoring_ip" {
  value = data.azurerm_network_interface.monitoring.0.private_ip_address
}

output "monitoring_public_ip" {
  value = data.azurerm_public_ip.monitoring.0.ip_address
}

output "monitoring_name" {
  value = azurerm_virtual_machine.monitoring.0.name
}

output "monitoring_public_name" {
  value = data.azurerm_public_ip.monitoring.0.fqdn
}
