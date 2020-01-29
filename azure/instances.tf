# Launch SLES-HAE of SLES4SAP cluster nodes

# Availability set for the VMs

resource "azurerm_availability_set" "hana-availability-set" {
  name                        = "avset-hana"
  location                    = var.az_region
  resource_group_name         = azurerm_resource_group.myrg.name
  managed                     = "true"
  platform_fault_domain_count = 2

  tags = {
    workspace = terraform.workspace
  }
}

# iSCSI server VM

resource "azurerm_virtual_machine" "iscsisrv" {
  name                  = "vmiscsisrv"
  location              = var.az_region
  resource_group_name   = azurerm_resource_group.myrg.name
  network_interface_ids = [azurerm_network_interface.iscsisrv.id]
  vm_size               = "Standard_D2s_v3"

  storage_os_disk {
    name              = "disk-iscsisrv-Os"
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
    name              = "disk-iscsisrv-Data01"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = "10"
    lun               = "0"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "iscsisrv"
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
    storage_uri = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  }

  tags = {
    workspace = terraform.workspace
  }
}

# monitoring VM

