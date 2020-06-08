locals {
  bastion_enabled = var.bastion_enabled ? 1 : 0
}


resource "azurerm_subnet" "bastion" {
  count                = local.bastion_enabled
  name                 = "snet-bastion"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefix       = var.snet_address_range
}

resource "azurerm_network_security_group" "bastion" {
  count               = local.bastion_enabled
  name                = "nsg-bastion"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "OUTALL"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  count                     = local.bastion_enabled
  subnet_id                 = azurerm_subnet.bastion[0].id
  network_security_group_id = azurerm_network_security_group.bastion[0].id
}

resource "azurerm_network_interface" "bastion" {
  count                     = local.bastion_enabled
  name                      = "nic-bastion"
  location                  = var.az_region
  resource_group_name       = var.resource_group_name
  network_security_group_id = azurerm_network_security_group.bastion[0].id

  ip_configuration {
    name                          = "ipconf-primary"
    subnet_id                     = azurerm_subnet.bastion[0].id
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(var.snet_address_range, 5)
    public_ip_address_id          = azurerm_public_ip.bastion[0].id
  }

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_public_ip" "bastion" {
  count                   = local.bastion_enabled
  name                    = "pip-bastion"
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_virtual_machine" "bastion" {
  count                            = local.bastion_enabled
  name                             = "vmbastion"
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [azurerm_network_interface.bastion[0].id]
  vm_size                          = "Standard_D2s_v3"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "disk-bastion-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "SUSE"
    offer     = "sles-sap-15-sp1-byos"
    sku       = "gen2"
    version   = "latest"
  }

  os_profile {
    computer_name  = "vmbastion"
    admin_username = var.admin_user
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = file(var.public_key_location)
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = var.storage_account
  }

  tags = {
    workspace = terraform.workspace
  }
}
