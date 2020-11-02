data "azurerm_public_ip" "iscsisrv" {
  count               = local.bastion_enabled ? 0 : var.iscsi_count
  name                = element(azurerm_public_ip.iscsisrv.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.iscsisrv.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on          = [azurerm_virtual_machine.iscsisrv]
}

data "azurerm_network_interface" "iscsisrv" {
  count               = var.iscsi_count
  name                = element(azurerm_network_interface.iscsisrv.*.name, count.index)
  resource_group_name = element(azurerm_virtual_machine.iscsisrv.*.resource_group_name, count.index)
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on          = [azurerm_virtual_machine.iscsisrv]
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
