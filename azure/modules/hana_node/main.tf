# Availability set for the hana VMs

locals {
  bastion_enabled             = var.common_variables["bastion_enabled"]
  create_ha_infra             = var.hana_count > 1 && var.common_variables["hana"]["ha_enabled"] ? 1 : 0
  create_active_active_infra = local.create_ha_infra == 1 && var.common_variables["hana"]["cluster_vip_secondary"] != "" ? 1 : 0
  provisioning_addresses      = local.bastion_enabled ? data.azurerm_network_interface.hana.*.private_ip_address : data.azurerm_public_ip.hana.*.ip_address
  hana_lb_rules_ports         = local.create_ha_infra == 1 ? toset([
    "3${var.hana_instance_number}13",
    "3${var.hana_instance_number}14",
    "3${var.hana_instance_number}40",
    "3${var.hana_instance_number}41",
    "3${var.hana_instance_number}42",
    "3${var.hana_instance_number}15",
    "3${var.hana_instance_number}17"
  ]) : toset([])

  hana_lb_rules_ports_secondary = local.create_active_active_infra == 1 ? local.hana_lb_rules_ports : toset([])
}

resource "azurerm_availability_set" "hana-availability-set" {
  count                       = local.create_ha_infra
  name                        = "avset-hana"
  location                    = var.az_region
  resource_group_name         = var.resource_group_name
  managed                     = "true"
  platform_fault_domain_count = 2

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# hana load balancer items

resource "azurerm_lb" "hana-load-balancer" {
  count               = local.create_ha_infra
  name                = "lb-hana"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "lbfe-hana"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.common_variables["hana"]["cluster_vip"]
  }

  # Create a new frontend for the Active/Active scenario
  dynamic "frontend_ip_configuration" {
    for_each = local.create_active_active_infra == 1 ? [var.common_variables["hana"]["cluster_vip_secondary"]] : []
    content {
      name                          = "lbfe-hana-secondary"
      subnet_id                     = var.network_subnet_id
      private_ip_address_allocation = "static"
      private_ip_address            = frontend_ip_configuration.value
    }
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# backend pools

resource "azurerm_lb_backend_address_pool" "hana-load-balancer" {
  count               = local.create_ha_infra
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.hana-load-balancer[0].id
  name                = "lbbe-hana"
}

resource "azurerm_network_interface_backend_address_pool_association" "hana" {
  count                   = var.common_variables["hana"]["ha_enabled"] ? var.hana_count : 0
  network_interface_id    = element(azurerm_network_interface.hana.*.id, count.index)
  ip_configuration_name   = "ipconf-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.hana-load-balancer[0].id
}

resource "azurerm_lb_probe" "hana-load-balancer" {
  count               = local.create_ha_infra
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.hana-load-balancer[0].id
  name                = "lbhp-hana"
  protocol            = "Tcp"
  port                = tonumber("625${var.hana_instance_number}")
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_probe" "hana-load-balancer-secondary" {
  count               = local.create_active_active_infra
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.hana-load-balancer[0].id
  name                = "lbhp-hana-secondary"
  protocol            = "Tcp"
  port                = tonumber("626${var.hana_instance_number}")
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load balancing rules for HANA 2.0
resource "azurerm_lb_rule" "hana-lb-rules" {
  for_each                       = local.hana_lb_rules_ports
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.hana-load-balancer[0].id
  name                           = "lbrule-hana-tcp-${each.value}"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-hana"
  frontend_port                  = tonumber(each.value)
  backend_port                   = tonumber(each.value)
  backend_address_pool_id        = azurerm_lb_backend_address_pool.hana-load-balancer[0].id
  probe_id                       = azurerm_lb_probe.hana-load-balancer[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

# Load balancing rules for the Active/Active setup
resource "azurerm_lb_rule" "hana-lb-rules-secondary" {
  for_each                       = local.hana_lb_rules_ports_secondary
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.hana-load-balancer[0].id
  name                           = "lbrule-hana-tcp-${each.value}-secondary"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-hana-secondary"
  frontend_port                  = tonumber(each.value)
  backend_port                   = tonumber(each.value)
  backend_address_pool_id        = azurerm_lb_backend_address_pool.hana-load-balancer[0].id
  probe_id                       = azurerm_lb_probe.hana-load-balancer-secondary[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "hanadb_exporter" {
  count                          = var.common_variables["monitoring_enabled"] ? local.create_ha_infra : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.hana-load-balancer[0].id
  name                           = "hanadb_exporter"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-hana"
  frontend_port                  = 9668
  backend_port                   = 9668
  backend_address_pool_id        = azurerm_lb_backend_address_pool.hana-load-balancer[0].id
  probe_id                       = azurerm_lb_probe.hana-load-balancer[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

# hana network configuration

resource "azurerm_network_interface" "hana" {
  count                         = var.hana_count
  name                          = "nic-${var.name}0${count.index + 1}"
  location                      = var.az_region
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "ipconf-primary"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.host_ips, count.index)
    public_ip_address_id          = local.bastion_enabled ? null : element(azurerm_public_ip.hana.*.id, count.index)
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

resource "azurerm_public_ip" "hana" {
  count                   = local.bastion_enabled ? 0 : var.hana_count
  name                    = "pip-${var.name}0${count.index + 1}"
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

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

# hana instances

module "os_image_reference" {
  source   = "../../modules/os_image_reference"
  os_image = var.os_image
}

locals {
  disks_number           = length(split(",", var.hana_data_disks_configuration["disks_size"]))
  disks_size             = [for disk_size in split(",", var.hana_data_disks_configuration["disks_size"]) : tonumber(trimspace(disk_size))]
  disks_type             = [for disk_type in split(",", var.hana_data_disks_configuration["disks_type"]) : trimspace(disk_type)]
  disks_caching          = [for caching in split(",", var.hana_data_disks_configuration["caching"]) : trimspace(caching)]
  disks_writeaccelerator = [for writeaccelerator in split(",", var.hana_data_disks_configuration["writeaccelerator"]) : tobool(trimspace(writeaccelerator))]
}

resource "azurerm_virtual_machine" "hana" {
  count                            = var.hana_count
  name                             = "vm${var.name}0${count.index + 1}"
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [element(azurerm_network_interface.hana.*.id, count.index)]
  availability_set_id              = var.common_variables["hana"]["ha_enabled"] ? azurerm_availability_set.hana-availability-set[0].id : null
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
    id        = var.sles4sap_uri != "" ? join(",", azurerm_image.sles4sap.*.id) : ""
    publisher = var.sles4sap_uri != "" ? "" : module.os_image_reference.publisher
    offer     = var.sles4sap_uri != "" ? "" : module.os_image_reference.offer
    sku       = var.sles4sap_uri != "" ? "" : module.os_image_reference.sku
    version   = var.sles4sap_uri != "" ? "" : module.os_image_reference.version
  }

  dynamic "storage_data_disk" {
    for_each = [for v in range(local.disks_number) : { index = v }]
    content {
      name                      = "disk-${var.name}0${count.index + 1}-Data0${storage_data_disk.value.index + 1}"
      managed_disk_type         = element(local.disks_type, storage_data_disk.value.index)
      create_option             = "Empty"
      lun                       = storage_data_disk.value.index
      disk_size_gb              = element(local.disks_size, storage_data_disk.value.index)
      caching                   = element(local.disks_caching, storage_data_disk.value.index)
      write_accelerator_enabled = element(local.disks_writeaccelerator, storage_data_disk.value.index)
    }
  }

  os_profile {
    computer_name  = "vm${var.name}0${count.index + 1}"
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

module "hana_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.hana_count
  instance_ids         = azurerm_virtual_machine.hana.*.id
  user                 = var.common_variables["authorized_user"]
  private_key          = var.common_variables["private_key"]
  bastion_host         = var.bastion_host
  bastion_private_key  = var.common_variables["bastion_private_key"]
  public_ips           = local.provisioning_addresses
  dependencies         = [data.azurerm_public_ip.hana]
}
