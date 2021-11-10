output "bastion_public_ip" {
  value = azurerm_public_ip.public_ip["pip-bastion-lb-fe"].ip_address
}

output "bastion_public_ip_id" {
  value = azurerm_public_ip.public_ip["pip-bastion-lb-fe"].id
}
