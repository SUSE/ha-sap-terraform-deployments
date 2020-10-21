data "azurerm_public_ip" "iscsisrv" {
  count               = local.bastion_enabled ? 0 : var.iscsi_count
  name                = element(azurerm_public_ip.iscsisrv.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.iscsisrv.*.resource_group_name, count.index)
}

data "azurerm_network_interface" "iscsisrv" {
  count               = var.iscsi_count
  name                = element(azurerm_network_interface.iscsisrv.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.iscsisrv.*.resource_group_name, count.index)
}

output "iscsisrv_ip" {
  value = data.azurerm_network_interface.iscsisrv.*.private_ip_address
}

output "iscsisrv_public_ip" {
  value = data.azurerm_public_ip.iscsisrv.*.ip_address
}

output "iscsisrv_name" {
  value = azurerm_virtual_machine.iscsisrv.*.name
}

output "iscsisrv_public_name" {
  value = data.azurerm_public_ip.iscsisrv.*.fqdn
}
