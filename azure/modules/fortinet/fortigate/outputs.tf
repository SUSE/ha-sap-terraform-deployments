output "fortigate_virtual_public_ip" {
  value = azurerm_public_ip.public_ip["pip-fgt-v"].ip_address
}

output "fortigate_a_management_public_ip" {
  value = azurerm_public_ip.public_ip["pip-fgt-a"].ip_address
}

output "fortigate_b_management_public_ip" {
  value = azurerm_public_ip.public_ip["pip-fgt-b"].ip_address
}
output "bastion_public_ip" {
  value = azurerm_public_ip.public_ip["pip-bastion-lb-fe"].ip_address
}

output "bastion_public_ip_id" {
  value = azurerm_public_ip.public_ip["pip-bastion-lb-fe"].id
}

output "fortigate_a_id" {
  value = azurerm_virtual_machine.virtual_machine["vm-fgt-a"].id
}

output "fortigate_b_id" {
  value = azurerm_virtual_machine.virtual_machine["vm-fgt-b"].id
}

