# iscsi server network configuration

resource "azurerm_network_interface" "iscsisrv" {
  count                     = var.iscsi_count
  name                      = "nic-iscsisrv0${count.index + 1}"
  location                  = var.az_region
  resource_group_name       = var.resource_group_name
  network_security_group_id = var.sec_group_id

  ip_configuration {
    name                          = "ipconf-primary"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.host_ips, count.index)
    public_ip_address_id          = element(azurerm_public_ip.iscsisrv.*.id, count.index)
  }

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_public_ip" "iscsisrv" {
  count                   = var.iscsi_count
  name                    = "pip-iscsisrv0${count.index + 1}"
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = terraform.workspace
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
    workspace = terraform.workspace
  }
}

# iSCSI server VM

resource "azurerm_virtual_machine" "iscsisrv" {
  count                            = var.iscsi_count
  name                             = "vmiscsisrv0${count.index + 1}"
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [element(azurerm_network_interface.iscsisrv.*.id, count.index)]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "disk-iscsisrv0${count.index + 1}-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.iscsi_srv_uri != "" ? join(",", azurerm_image.iscsi_srv.*.id) : ""
    publisher = var.iscsi_srv_uri != "" ? "" : var.iscsi_public_publisher
    offer     = var.iscsi_srv_uri != "" ? "" : var.iscsi_public_offer
    sku       = var.iscsi_srv_uri != "" ? "" : var.iscsi_public_sku
    version   = var.iscsi_srv_uri != "" ? "" : var.iscsi_public_version
  }

  storage_data_disk {
    name              = "disk-iscsisrv0${count.index + 1}-Data01"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = var.iscsi_disk_size
    lun               = "0"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "vmiscsisrv"
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

module "iscsi_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.iscsi_count
  instance_ids         = azurerm_virtual_machine.iscsisrv.*.id
  user                 = var.admin_user
  private_key_location = var.private_key_location
  public_ips           = data.azurerm_public_ip.iscsisrv.*.ip_address
  dependencies         = [data.azurerm_public_ip.iscsisrv]
}
