# monitoring network configuration

locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = local.bastion_enabled ? data.azurerm_network_interface.monitoring.*.private_ip_address : data.azurerm_public_ip.monitoring.*.ip_address
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "azurerm_network_interface" "monitoring" {
  name                = "nic-monitoring"
  count               = var.monitoring_enabled == true ? 1 : 0
  location            = var.az_region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name = "ipconf-primary"
    subnet_id                     = var.snet_id == "" ? var.network_subnet_id : var.snet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.monitoring_srv_ip
    public_ip_address_id = local.bastion_enabled ? null : azurerm_public_ip.monitoring.0.id
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
    role      = "monitoring_srv"
  }
}

resource "azurerm_public_ip" "monitoring" {
  name                    = "pip-monitoring"
  count                   = local.bastion_enabled ? 0 : (var.monitoring_enabled ? 1 : 0)
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = var.common_variables["deployment_name"]
    role      = "monitoring_srv"
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
    workspace = var.common_variables["deployment_name"]
    role      = "monitoring_srv"
  }
}

# monitoring VM

module "os_image_reference" {
  source   = "../../modules/os_image_reference"
  os_image = var.os_image
}

resource "azurerm_virtual_machine" "monitoring" {
  name                             = var.name
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
    publisher = var.monitoring_uri != "" ? "" : module.os_image_reference.publisher
    offer     = var.monitoring_uri != "" ? "" : module.os_image_reference.offer
    sku       = var.monitoring_uri != "" ? "" : module.os_image_reference.sku
    version   = var.monitoring_uri != "" ? "" : module.os_image_reference.version
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
    computer_name  = local.hostname
    admin_username = var.common_variables["authorized_user"]
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.common_variables["authorized_user"]}/.ssh/authorized_keys"
      key_data = var.common_variables["public_key"]
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = var.storage_account
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
    role      = "monitoring_srv"
  }
}

module "monitoring_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.monitoring_enabled ? 1 : 0
  instance_ids        = azurerm_virtual_machine.monitoring.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  dependencies        = [data.azurerm_public_ip.monitoring]
}
