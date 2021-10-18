resource "azurerm_network_interface" "fortigate_nic_a" {
  count = 4

  name                = format("nic-fortigate_a_%s", count.index + 1)
  location            = var.az_region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.snet_ids[count.index]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.snet_address_ranges[count.index], 6)
    #public_ip_address_id          = azurerm_public_ip.bastion[0].id
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

resource "azurerm_network_interface" "fortigate_nic_b" {
  count = 4

  name                = format("nic-fortigate_b_%s", count.index + 1)
  location            = var.az_region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.snet_ids[count.index]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.snet_address_ranges[count.index], 7)
    #public_ip_address_id          = azurerm_public_ip.bastion[0].id
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}