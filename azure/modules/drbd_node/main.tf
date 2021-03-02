# drbd deployment in Azure to host a HA NFS share for SAP Netweaver
# official documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-nfs
# disclaimer: only supports a single NW installation

locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = local.bastion_enabled ? data.azurerm_network_interface.drbd.*.private_ip_address : data.azurerm_public_ip.drbd.*.ip_address
}

resource "azurerm_availability_set" "drbd-availability-set" {
  count                       = var.drbd_count > 0 ? 1 : 0
  name                        = "avset-drbd"
  location                    = var.az_region
  resource_group_name         = var.resource_group_name
  managed                     = "true"
  platform_fault_domain_count = 2

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# drbd load balancer items

resource "azurerm_lb" "drbd-load-balancer" {
  count               = var.drbd_count > 0 ? 1 : 0
  name                = "lb-drbd"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "lbfe-drbd"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.drbd_cluster_vip
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

resource "azurerm_lb_backend_address_pool" "drbd-backend-pool" {
  count               = var.drbd_count > 0 ? 1 : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.drbd-load-balancer[0].id
  name                = "lbbe-drbd"
}

resource "azurerm_network_interface_backend_address_pool_association" "drbd-nodes" {
  count                   = var.drbd_count
  network_interface_id    = element(azurerm_network_interface.drbd.*.id, count.index)
  ip_configuration_name   = "ipconf-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.drbd-backend-pool[0].id
}

resource "azurerm_lb_probe" "drbd-health-probe" {
  count               = var.drbd_count > 0 ? 1 : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.drbd-load-balancer[0].id
  name                = "lbhp-drbd"
  protocol            = "Tcp"
  port                = 61000
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Only for Standard load balancer, which requires other more expensive registration
#resource "azurerm_lb_rule" "drbd-lb-ha" {
#  count                          = var.drbd_count > 0 ? 1 : 0
#  resource_group_name            = var.resource_group_name
#  loadbalancer_id                = azurerm_lb.drbd-load-balancer.id
#  name                           = "drbd-lb-ha"
#  protocol                       = "All"
#  frontend_ip_configuration_name = "drbd-frontend"
#  frontend_port                  = 0
#  backend_port                   = 0
#  backend_address_pool_id        = azurerm_lb_backend_address_pool.drbd-backend-pool[0].id
#  probe_id                       = azurerm_lb_probe.drbd-health-probe.id
#  idle_timeout_in_minutes        = 30
#  enable_floating_ip             = "true"
#}

resource "azurerm_lb_rule" "drbd-lb-tcp-2049" {
  count                          = var.drbd_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.drbd-load-balancer[0].id
  name                           = "lbrule-drbd-tcp-2049"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-drbd"
  frontend_port                  = 2049
  backend_port                   = 2049
  backend_address_pool_id        = azurerm_lb_backend_address_pool.drbd-backend-pool[count.index].id
  probe_id                       = azurerm_lb_probe.drbd-health-probe[count.index].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "drbd-lb-udp-2049" {
  count                          = var.drbd_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.drbd-load-balancer[0].id
  name                           = "lbrule-drbd-udp-2049"
  protocol                       = "Udp"
  frontend_ip_configuration_name = "lbfe-drbd"
  frontend_port                  = 2049
  backend_port                   = 2049
  backend_address_pool_id        = azurerm_lb_backend_address_pool.drbd-backend-pool[count.index].id
  probe_id                       = azurerm_lb_probe.drbd-health-probe[count.index].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

# drbd network configuration

resource "azurerm_public_ip" "drbd" {
  count                   = local.bastion_enabled ? 0 : var.drbd_count
  name                    = "pip-drbd0${count.index + 1}"
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

resource "azurerm_network_interface" "drbd" {
  count                     = var.drbd_count
  name                      = "nic-drbd0${count.index + 1}"
  location                  = var.az_region
  resource_group_name       = var.resource_group_name

  ip_configuration {
    name                          = "ipconf-primary"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.host_ips, count.index)
    public_ip_address_id          = local.bastion_enabled ? null : element(azurerm_public_ip.drbd.*.id, count.index)
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# drbd custom image. only available is drbd_image_uri is used

resource "azurerm_image" "drbd-image" {
  count               = var.drbd_image_uri != "" ? 1 : 0
  name                = "drbd-image"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.drbd_image_uri
    size_gb  = "32"
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# drbd instances

module "os_image_reference" {
  source   = "../../modules/os_image_reference"
  os_image = var.os_image
}

resource "azurerm_virtual_machine" "drbd" {
  count                            = var.drbd_count
  name                             = "vm${var.name}0${count.index + 1}"
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [element(azurerm_network_interface.drbd.*.id, count.index)]
  availability_set_id              = azurerm_availability_set.drbd-availability-set[0].id
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "disk-${var.name}0${count.index + 1}-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.drbd_image_uri != "" ? join(",", azurerm_image.drbd-image.*.id) : ""
    publisher = var.drbd_image_uri != "" ? "" : module.os_image_reference.publisher
    offer     = var.drbd_image_uri != "" ? "" : module.os_image_reference.offer
    sku       = var.drbd_image_uri != "" ? "" : module.os_image_reference.sku
    version   = var.drbd_image_uri != "" ? "" : module.os_image_reference.version
  }

  storage_data_disk {
    name              = "disk-${var.name}0${count.index + 1}-Data01"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = "10"
    lun               = "0"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vmdrbd0${count.index + 1}"
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

module "drbd_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.drbd_count
  instance_ids         = azurerm_virtual_machine.drbd.*.id
  user                 = var.common_variables["authorized_user"]
  private_key          = var.common_variables["private_key"]
  bastion_host         = var.bastion_host
  bastion_private_key  = var.common_variables["bastion_private_key"]
  public_ips           = local.provisioning_addresses
  dependencies         = [data.azurerm_public_ip.drbd]
}
