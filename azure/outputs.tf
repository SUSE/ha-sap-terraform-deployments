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

# Hana nodes

data "azurerm_public_ip" "hana" {
  count = var.ninstances
  name  = element(azurerm_public_ip.hana.*.name, count.index)
  resource_group_name = element(
    azurerm_virtual_machine.hana.*.resource_group_name,
    count.index,
  )
}

data "azurerm_network_interface" "hana" {
  count = var.ninstances
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

# Monitoring

output "monitoring_ip" {
  value = module.monitoring.monitoring_ip
}

output "monitoring_public_ip" {
  value = module.monitoring.monitoring_public_ip
}

output "monitoring_name" {
  value = module.monitoring.monitoring_name
}

output "monitoring_public_name" {
  value = module.monitoring.monitoring_public_name
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
