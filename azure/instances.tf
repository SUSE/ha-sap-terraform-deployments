# Launch SLES-HAE of SLES4SAP cluster nodes

# Availability set for the VMs

resource "azurerm_availability_set" "myas" {
  name                        = "myas"
  location                    = var.az_region
  resource_group_name         = azurerm_resource_group.myrg.name
  platform_fault_domain_count = 2
  managed                     = "true"

  tags = {
    workspace = terraform.workspace
  }
}

# iSCSI server VM

resource "azurerm_virtual_machine" "iscsisrv" {
  name                  = "${terraform.workspace}-iscsisrv"
  location              = var.az_region
  resource_group_name   = azurerm_resource_group.myrg.name
  network_interface_ids = [azurerm_network_interface.iscsisrv.id]
  availability_set_id   = azurerm_availability_set.myas.id
  vm_size               = "Standard_D2s_v3"

  storage_os_disk {
    name              = "iscsiOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.iscsi_srv_uri != "" ? join(",", azurerm_image.iscsi_srv.*.id) : ""
    publisher = var.iscsi_srv_uri != "" ? "" : var.iscsi_publisher
    offer     = var.iscsi_srv_uri != "" ? "" : var.iscsi_public_offer
    sku       = var.iscsi_srv_uri != "" ? "" : var.iscsi_public_sku
    version   = var.iscsi_srv_uri != "" ? "" : var.iscsi_public_version
  }

  storage_data_disk {
    name              = "iscsiDevices"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = "10"
    lun               = "0"
    managed_disk_type = "Standard_LRS"
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

# Cluster Nodes

resource "azurerm_virtual_machine" "clusternodes" {
  count                 = var.ninstances
  name                  = "${terraform.workspace}-node-${count.index}"
  location              = var.az_region
  resource_group_name   = azurerm_resource_group.myrg.name
  network_interface_ids = [element(azurerm_network_interface.clusternodes.*.id, count.index)]
  availability_set_id   = azurerm_availability_set.myas.id
  vm_size               = var.instancetype

  storage_os_disk {
    name              = "NodeOsDisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.sles4sap_uri != "" ? join(",", azurerm_image.sles4sap.*.id) : ""
    publisher = var.sles4sap_uri != "" ? "" : var.hana_public_publisher
    offer     = var.sles4sap_uri != "" ? "" : var.hana_public_offer
    sku       = var.sles4sap_uri != "" ? "" : var.hana_public_sku
    version   = var.sles4sap_uri != "" ? "" : var.hana_public_version
  }

  storage_data_disk {
    name              = "node-data-disk-${count.index}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "60"
  }

  os_profile {
    computer_name  = "${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}"
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

