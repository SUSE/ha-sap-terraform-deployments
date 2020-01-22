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

# Monitoring

data "azurerm_public_ip" "monitoring" {
  count               = var.monitoring_enabled == true ? 1 : 0
  name                = azurerm_public_ip.monitoring.0.name
  resource_group_name = azurerm_virtual_machine.monitoring.0.resource_group_name
}

data "azurerm_network_interface" "monitoring" {
  count               = var.monitoring_enabled == true ? 1 : 0
  name                = azurerm_network_interface.monitoring.0.name
  resource_group_name = azurerm_virtual_machine.monitoring.0.resource_group_name
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

# Hana nodes

output "cluster_nodes_ip" {
  value = module.hana_node.cluster_nodes_ip
}

output "cluster_nodes_public_ip" {
  value = module.hana_node.cluster_nodes_public_ip
}

output "cluster_nodes_name" {
  value = module.hana_node.cluster_nodes_name
}

output "cluster_nodes_public_name" {
  value = module.hana_node.cluster_nodes_public_name
}

# drbd

output "drbd_ip" {
  value = module.drbd_node.drbd_ip
}

output "drbd_public_ip" {
  value = module.drbd_node.drbd_public_ip
}

output "drbd_name" {
  value = module.drbd_node.drbd_name
}

output "drbd_public_name" {
  value = module.drbd_node.drbd_public_name
}

# netweaver

output "netweaver_ip" {
  value = module.netweaver_node.netweaver_ip
}

output "netweaver_public_ip" {
  value = module.netweaver_node.netweaver_public_ip
}

output "netweaver_name" {
  value = module.netweaver_node.netweaver_name
}

output "netweaver_public_name" {
  value = module.netweaver_node.netweaver_public_name
}
