data "azurerm_public_ip" "bastion" {
  count               = !var.fortinet_enabled ? local.bastion_count : 0
  name                = azurerm_public_ip.bastion.0.name
  resource_group_name = azurerm_virtual_machine.bastion.0.resource_group_name
  # depends_on is included to avoid the issue with `resource_group was not found`. Find an example in: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8476
  depends_on = [azurerm_virtual_machine.bastion]
}

output "public_ip" {
  # if existing hub_spoke is used, a bastion host IP needs to be passed
  # otherwise use fortinet IP or the one created by this module
  value = var.network_topology == "hub_spoke" && var.vnet_hub_create == false ? var.bastion_host : (var.fortinet_enabled ? var.fortinet_bastion_public_ip : join("", data.azurerm_public_ip.bastion.*.ip_address))
}

output "subnet_bastion_id" {
  value = local.bastion_count == 1 && var.network_topology == "plain" ? azurerm_subnet.bastion.0.id : ""
}

output "provisioned" {
  value = module.bastion_provision.provisioned
}
