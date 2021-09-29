# iscsi server network configuration

locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = local.bastion_enabled ? data.azurerm_network_interface.iscsisrv.*.private_ip_address : data.azurerm_public_ip.iscsisrv.*.ip_address
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "azurerm_network_interface" "iscsisrv" {
  count               = var.iscsi_count
  name                = "nic-iscsisrv${format("%02d", count.index + 1)}"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconf-primary"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.host_ips, count.index)
    public_ip_address_id          = local.bastion_enabled ? null : element(azurerm_public_ip.iscsisrv.*.id, count.index)
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

resource "azurerm_public_ip" "iscsisrv" {
  count                   = local.bastion_enabled ? 0 : var.iscsi_count
  name                    = "pip-iscsisrv${format("%02d", count.index + 1)}"
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# iscsi server custom image. only available if iscsi_image_uri is used

resource "azurerm_image" "iscsi_srv" {
  count               = var.iscsi_srv_uri != "" ? 1 : 0
  name                = "IscsiSrvImg"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.iscsi_srv_uri
    size_gb  = "32"
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# iSCSI server VM

module "os_image_reference" {
  source   = "../../modules/os_image_reference"
  os_image = var.os_image
}

resource "azurerm_virtual_machine" "iscsisrv" {
  count                            = var.iscsi_count
  name                             = "${var.name}${format("%02d", count.index + 1)}"
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [element(azurerm_network_interface.iscsisrv.*.id, count.index)]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "disk-iscsisrv${format("%02d", count.index + 1)}-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.iscsi_srv_uri != "" ? join(",", azurerm_image.iscsi_srv.*.id) : ""
    publisher = var.iscsi_srv_uri != "" ? "" : module.os_image_reference.publisher
    offer     = var.iscsi_srv_uri != "" ? "" : module.os_image_reference.offer
    sku       = var.iscsi_srv_uri != "" ? "" : module.os_image_reference.sku
    version   = var.iscsi_srv_uri != "" ? "" : module.os_image_reference.version
  }

  storage_data_disk {
    name              = "disk-iscsisrv${format("%02d", count.index + 1)}-Data01"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = var.iscsi_disk_size
    lun               = "0"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "${local.hostname}${format("%02d", count.index + 1)}"
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
    role      = "iscsi_srv"
  }
}

module "iscsi_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.iscsi_count
  instance_ids        = azurerm_virtual_machine.iscsisrv.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  dependencies        = [data.azurerm_public_ip.iscsisrv]
}
