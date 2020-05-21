# monitoring network configuration

resource "azurerm_network_interface" "monitoring" {
  name                      = "nic-monitoring"
  count                     = var.monitoring_enabled == true ? 1 : 0
  location                  = var.az_region
  resource_group_name       = var.resource_group_name
  network_security_group_id = var.sec_group_id

  ip_configuration {
    name                          = "ipconf-primary"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.monitoring_srv_ip
    public_ip_address_id          = azurerm_public_ip.monitoring.0.id
  }

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_public_ip" "monitoring" {
  name                    = "pip-monitoring"
  count                   = var.monitoring_enabled == true ? 1 : 0
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = terraform.workspace
  }
}

# monitoring custom image. only available if monitoring_image_uri is used

resource "azurerm_image" "monitoring" {
  count               = var.monitoring_uri != "" ? 1 : 0
  name                = "monitoringSrvImg"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.monitoring_uri
    size_gb  = "32"
  }

  tags = {
    workspace = terraform.workspace
  }
}

# monitoring VM

resource "azurerm_virtual_machine" "monitoring" {
  name                             = "vmmonitoring"
  count                            = var.monitoring_enabled == true ? 1 : 0
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [azurerm_network_interface.monitoring.0.id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "disk-monitoring-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.monitoring_uri != "" ? azurerm_image.monitoring.0.id : ""
    publisher = var.monitoring_uri != "" ? "" : var.monitoring_public_publisher
    offer     = var.monitoring_uri != "" ? "" : var.monitoring_public_offer
    sku       = var.monitoring_uri != "" ? "" : var.monitoring_public_sku
    version   = var.monitoring_uri != "" ? "" : var.monitoring_public_version
  }

  storage_data_disk {
    name              = "disk-monitoring-Data01"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = "10"
    lun               = "0"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vmmonitoring"
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

module "monitoring_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.monitoring_enabled ? 1 : 0
  instance_ids         = azurerm_virtual_machine.monitoring.*.id
  user                 = var.admin_user
  private_key_location = var.private_key_location
  public_ips           = data.azurerm_public_ip.monitoring.*.ip_address
  dependencies         = [data.azurerm_public_ip.monitoring]
}
