locals {
  bastion_enabled      = var.common_variables["bastion_enabled"]
  provisioning_address = local.bastion_enabled ? data.azurerm_network_interface.majority_maker.*.private_ip_address : data.azurerm_public_ip.majority_maker.*.ip_address
}


# majority maker network configuration

resource "azurerm_network_interface" "majority_maker" {
  count                         = var.node_count
  name                          = "nic-${var.name}majority_maker"
  location                      = var.az_region
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "ipconf-primary"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.majority_maker_ip
    public_ip_address_id          = local.bastion_enabled ? null : element(azurerm_public_ip.majority_maker.*.id, count.index)
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

resource "azurerm_public_ip" "majority_maker" {
  count                   = var.node_count
  name                    = "pip-${var.name}majority_maker"
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# majority maker instance

resource "azurerm_image" "sles4sap" {
  count               = var.sles4sap_uri != "" ? 1 : 0
  name                = "BVSles4SapImg"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.sles4sap_uri
    size_gb  = "32"
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

module "os_image_reference" {
  source   = "../../modules/os_image_reference"
  os_image = var.os_image
}

resource "azurerm_virtual_machine" "majority_maker" {
  count                 = var.node_count
  name                  = "vm${var.name}mm"
  location              = var.az_region
  resource_group_name   = var.resource_group_name
  network_interface_ids = [element(azurerm_network_interface.majority_maker.*.id, count.index)]
  # availability_set_id              = var.common_variables["hana"]["ha_enabled"] ? azurerm_availability_set.hana-availability-set[0].id : null
  vm_size                       = var.vm_size
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "disk-${var.name}majority_maker-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.sles4sap_uri != "" ? join(",", azurerm_image.sles4sap.*.id) : ""
    publisher = var.sles4sap_uri != "" ? "" : module.os_image_reference.publisher
    offer     = var.sles4sap_uri != "" ? "" : module.os_image_reference.offer
    sku       = var.sles4sap_uri != "" ? "" : module.os_image_reference.sku
    version   = var.sles4sap_uri != "" ? "" : module.os_image_reference.version
  }

  os_profile {
    computer_name  = "vm${var.name}mm"
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
  }
}

module "majority_maker_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.node_count
  instance_ids        = azurerm_virtual_machine.majority_maker.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_address
  dependencies        = [data.azurerm_public_ip.majority_maker]
}
