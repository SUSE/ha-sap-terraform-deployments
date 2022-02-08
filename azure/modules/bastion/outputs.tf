data "azurerm_public_ip" "bastion" {
  count               = var.fortinet_enabled ? 0 : 1
  name                = azurerm_public_ip.bastion.0.name
  resource_group_name = azurerm_virtual_machine.bastion.resource_group_name
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on = [azurerm_virtual_machine.bastion]
}

output "public_ip" {
  # if existing hub_spoke is used, a bastion host IP needs to be passed
  # otherwise use fortinet IP or the one created by this module
  value = var.fortinet_enabled ? var.fortinet_bastion_public_ip : join("", data.azurerm_public_ip.bastion.*.ip_address)
}

output "subnet_bastion_id" {
  value = var.network_topology == "plain" ? azurerm_subnet.bastion.0.id : ""
}

output "provisioner" {
  value = null_resource.bastion_provisioner
}
