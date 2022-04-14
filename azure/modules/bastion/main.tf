locals {
  private_ip_address = cidrhost(var.snet_address_range, 5)
  public_ip_address  = var.fortinet_enabled ? var.fortinet_bastion_public_ip : join("", data.azurerm_public_ip.bastion.*.ip_address)
  hostname           = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "azurerm_subnet" "bastion" {
  count                = var.network_topology == "plain" ? 1 : 0
  name                 = "snet-bastion"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.snet_address_range]
}

resource "azurerm_network_security_group" "bastion" {
  count               = var.network_topology == "plain" ? 1 : 0
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
    destination_address_prefix = local.private_ip_address
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

resource "azurerm_network_security_rule" "grafana" {
  count                       = var.common_variables["monitoring_enabled"] && var.network_topology == "plain" ? 1 : 0
  name                        = "Grafana"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = local.private_ip_address
  resource_group_name         = var.resource_group_name
  network_security_group_name = join("", azurerm_network_security_group.bastion.*.name)
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  count                     = var.network_topology == "plain" ? 1 : 0
  subnet_id                 = azurerm_subnet.bastion.0.id
  network_security_group_id = azurerm_network_security_group.bastion.0.id
}

resource "azurerm_network_interface" "bastion" {
  name                = "nic-bastion"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconf-primary"
    subnet_id                     = var.snet_id == "" ? azurerm_subnet.bastion.0.id : var.snet_id
    private_ip_address_allocation = "static"
    private_ip_address            = local.private_ip_address
    public_ip_address_id          = !var.fortinet_enabled ? azurerm_public_ip.bastion.0.id : ""
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
    role      = "bastion"
  }
}

resource "azurerm_public_ip" "bastion" {
  count                   = var.fortinet_enabled ? 0 : 1
  name                    = "pip-bastion"
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = var.common_variables["deployment_name"]
    role      = "bastion"
  }
}

module "os_image_reference" {
  source   = "../../modules/os_image_reference"
  os_image = var.os_image
}

resource "azurerm_virtual_machine" "bastion" {
  name                             = var.name
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [azurerm_network_interface.bastion.id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "disk-bastion-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = module.os_image_reference.publisher
    offer     = module.os_image_reference.offer
    sku       = module.os_image_reference.sku
    version   = module.os_image_reference.version
  }

  os_profile {
    computer_name  = local.hostname
    admin_username = var.common_variables["authorized_user"]
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.common_variables["authorized_user"]}/.ssh/authorized_keys"
      key_data = var.common_variables["bastion_public_key"]
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = var.storage_account
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
    role      = "bastion"
  }
}

module "bastion_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = local.node_count
  instance_ids = azurerm_virtual_machine.bastion.*.id
  user         = var.common_variables["authorized_user"]
  private_key  = var.common_variables["bastion_private_key"]
  public_ips   = [local.public_ip_address]

  dependencies = [local.public_ip_address]
}
