# netweaver deployment in Azure
# official documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse

locals {
  vm_count               = var.xscs_server_count + var.app_server_count
  bastion_enabled        = var.common_variables["bastion_enabled"]
  create_ha_infra        = var.xscs_server_count > 0 && var.common_variables["netweaver"]["ha_enabled"] ? 1 : 0
  additional_lun_number  = "0"
  provisioning_addresses = local.bastion_enabled ? data.azurerm_network_interface.netweaver.*.private_ip_address : data.azurerm_public_ip.netweaver.*.ip_address
  ascs_lb_rules_ports    = local.create_ha_infra == 1 ? toset([
    "32${var.ascs_instance_number}",
    "36${var.ascs_instance_number}",
    "39${var.ascs_instance_number}",
    "81${var.ascs_instance_number}",
    "5${var.ascs_instance_number}13",
    "5${var.ascs_instance_number}14",
    "5${var.ascs_instance_number}16",
    "9680" # monitoring - sap_host_exporter
  ]) : toset([])
  ers_lb_rules_ports     = local.create_ha_infra == 1 ? toset([
    "32${var.ers_instance_number}",
    "33${var.ers_instance_number}",
    "5${var.ers_instance_number}13",
    "5${var.ers_instance_number}14",
    "5${var.ers_instance_number}16",
    "9680" # monitoring - sap_host_exporter
  ]) : toset([])
}

resource "azurerm_availability_set" "netweaver-xscs-availability-set" {
  count                       = local.create_ha_infra
  name                        = "avset-xscs-netweaver"
  location                    = var.az_region
  resource_group_name         = var.resource_group_name
  managed                     = "true"
  platform_fault_domain_count = 2

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

resource "azurerm_availability_set" "netweaver-app-availability-set" {
  count                        = var.app_server_count > 0 ? 1 : 0
  name                         = "avset-app-netweaver"
  location                     = var.az_region
  resource_group_name          = var.resource_group_name
  managed                      = "true"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 10

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# netweaver load balancer items

resource "azurerm_lb" "netweaver-load-balancer" {
  count               = local.create_ha_infra
  name                = "lb-netweaver"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "lbfe-netweaver-ascs"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.virtual_host_ips, 0)
  }

  frontend_ip_configuration {
    name                          = "lbfe-netweaver-ers"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.virtual_host_ips, 1)
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# backend pools

resource "azurerm_lb_backend_address_pool" "netweaver-backend-pool" {
  count               = local.create_ha_infra
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.netweaver-load-balancer[0].id
  name                = "lbbe-netweaver"
}

resource "azurerm_network_interface_backend_address_pool_association" "netweaver-nodes" {
  count                   = local.create_ha_infra == 1 ? var.xscs_server_count : 0
  network_interface_id    = element(azurerm_network_interface.netweaver.*.id, count.index)
  ip_configuration_name   = "ipconf-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
}

# health probes
# example: Instance number: 00, port: 62000, Instance number: 01, port: 62001

resource "azurerm_lb_probe" "netweaver-ascs-health-probe" {
  count               = local.create_ha_infra
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.netweaver-load-balancer[0].id
  name                = "lbhp-netweaver-ascs"
  protocol            = "Tcp"
  port                = tonumber("620${var.ascs_instance_number}")
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_probe" "netweaver-ers-health-probe" {
  count               = local.create_ha_infra
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.netweaver-load-balancer[0].id
  name                = "lbhp-netweaver-ers"
  protocol            = "Tcp"
  port                = tonumber("621${var.ers_instance_number}")
  interval_in_seconds = 5
  number_of_probes    = 2
}

# load balancing rules. The ports must use the Netweaver instance number in their composition
# example: Instance number: 00, port: 3200, Instance number: 01, port: 3201

# Only for Standard load balancer, which requires other more expensive registration
#resource "azurerm_lb_rule" "netweaver-lb-ha-ascs" {
#  count                          = local.create_ha_infra
#  resource_group_name            = var.resource_group_name
#  loadbalancer_id                = azurerm_lb.netweaver-load-balancer.id
#  name                           = "lbrule-netweaver-ascs-all"
#  protocol                       = "All"
#  frontend_ip_configuration_name = "lbfe-netweaver-ascs"
#  frontend_port                  = 0
#  backend_port                   = 0
#  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
#  probe_id                       = azurerm_lb_probe.netweaver-health-probe[0].id
#  idle_timeout_in_minutes        = 30
#  enable_floating_ip             = "true"
#}

#resource "azurerm_lb_rule" "netweaver-lb-ha-ers" {
#  count                          = local.create_ha_infra
#  resource_group_name            = var.resource_group_name
#  loadbalancer_id                = azurerm_lb.netweaver-load-balancer.id
#  name                           = "lbrule-netweaver-ers-all"
#  protocol                       = "All"
#  frontend_ip_configuration_name = "lbfe-netweaver-ers"
#  frontend_port                  = 0
#  backend_port                   = 0
#  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[1].id
#  probe_id                       = azurerm_lb_probe.netweaver-health-probe[1].id
#  idle_timeout_in_minutes        = 30
#  enable_floating_ip             = "true"
#}

resource "azurerm_lb_rule" "ascs-lb-rules" {
  for_each                       = local.ascs_lb_rules_ports
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-netweaver-ascs-tcp-${each.value}"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ascs"
  frontend_port                  = tonumber(each.value)
  backend_port                   = tonumber(each.value)
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ascs-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "ers-lb-rules" {
  for_each                       = local.ers_lb_rules_ports
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-netweaver-ers-tcp-${each.value}"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ers"
  frontend_port                  = tonumber(each.value)
  backend_port                   = tonumber(each.value)
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ers-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

# netweaver network configuration

resource "azurerm_public_ip" "netweaver" {
  count                   = local.bastion_enabled ? 0 : local.vm_count
  name                    = "pip-netweaver0${count.index + 1}"
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

resource "azurerm_network_interface" "netweaver" {
  count                         = local.vm_count
  name                          = "nic-netweaver0${count.index + 1}"
  location                      = var.az_region
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = count.index < var.xscs_server_count ? var.xscs_accelerated_networking : var.app_accelerated_networking

  ip_configuration {
    name                          = "ipconf-primary"
    primary                       = true
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.host_ips, count.index)
    public_ip_address_id          = local.bastion_enabled ? null : element(azurerm_public_ip.netweaver.*.id, count.index)
  }

  # virtual IPs for PAS and AAS instances (if not configured on load-balancer)
  #
  # HA use case - PAS instance on additional machine
  # create_ha_infra = 1
  # xscs_server_count = 2 # ASCS+ERS
  # app_server_count = 1..X # PAS and APPX additional machines
  dynamic "ip_configuration" {
    # on HA, deploy not on ASCS+ERS (count.index(0|1) >= var.xscs_server_count(2))
    for_each = local.create_ha_infra == 1 ? (count.index >= var.xscs_server_count ? [1] : []) : []
    content {
      name                          = "ipconf-vip-ha-as"
      subnet_id                     = var.network_subnet_id
      private_ip_address_allocation = "static"
      private_ip_address            = element(var.virtual_host_ips, count.index)
    }
  }
  # HA use case - PAS instance on same machine as the ASCS
  # create_ha_infra = 1
  # xscs_server_count = 2 # ASCS+ERS
  # app_server_count = 0 # no PAS on additional machine
  dynamic "ip_configuration" {
    # on HA, test for PAS on ASCS scenario (app_server_count=0 && count.index=0[ASCS])
    for_each = local.create_ha_infra == 1 ? (var.app_server_count == 0 ? (count.index == 0 ? [1] : []) : []) : []
    content {
      name                          = "ipconf-vip-ha-pas-on-ascs"
      subnet_id                     = var.network_subnet_id
      private_ip_address_allocation = "static"
      private_ip_address            = element(var.virtual_host_ips, count.index + var.xscs_server_count)
    }
  }
  # non-HA use case - PAS instance on additional machine 
  # create_ha_infra = 0
  # xscs_server_count = 1 # ASCS
  # app_server_count = 1..X # PAS and APPX on additional machines
  dynamic "ip_configuration" {
    # on non-HA, deploy ASCS,PAS,APPX VIPs
    for_each = local.create_ha_infra == 0 ? [1] : []
    content {
      name                          = "ipconf-vip-non-ha-as"
      subnet_id                     = var.network_subnet_id
      private_ip_address_allocation = "static"
      private_ip_address            = element(var.virtual_host_ips, count.index)
    }
  }
  # non-HA use case - PAS instance on same machine as the ASCS
  # create_ha_infra = 0
  # xscs_server_count = 1 # ASCS
  # app_server_count = 0..X # no PAS on additional machine AND PAS on additional machines
  dynamic "ip_configuration" {
    # on non-HA, test for PAS on ASCS scenario (app_server_count=0 && count.index=0[ASCS])
    for_each = local.create_ha_infra == 0 ? (var.app_server_count == 0 ? (count.index == 0 ? [1] : []) : []) : []
    content {
      name                          = "ipconf-vip-non-ha-pas-on-ascs"
      subnet_id                     = var.network_subnet_id
      private_ip_address_allocation = "static"
      private_ip_address            = element(var.virtual_host_ips, count.index + var.xscs_server_count)
    }
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# netweaver custom image. only available is netweaver_image_uri is used

resource "azurerm_image" "netweaver-image" {
  count               = var.netweaver_image_uri != "" ? 1 : 0
  name                = "img-netweaver"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.netweaver_image_uri
    size_gb  = "32"
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

# APP server disk

resource "azurerm_managed_disk" "app_server_disk" {
  count                = var.app_server_count
  name                 = "disk-netweaver0${count.index + 1}-App"
  location             = var.az_region
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "app_server_disk" {
  count              = var.app_server_count
  managed_disk_id    = azurerm_managed_disk.app_server_disk[count.index].id
  virtual_machine_id = azurerm_virtual_machine.netweaver[count.index + var.xscs_server_count].id
  lun                = local.additional_lun_number
  caching            = var.data_disk_caching
}

# netweaver instances

module "os_image_reference" {
  source   = "../../modules/os_image_reference"
  os_image = var.os_image
}

resource "azurerm_virtual_machine" "netweaver" {
  count                            = local.vm_count
  name                             = "vmnetweaver0${count.index + 1}"
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [element(azurerm_network_interface.netweaver.*.id, count.index)]
  availability_set_id              = count.index < var.xscs_server_count ? (local.create_ha_infra > 0 ? azurerm_availability_set.netweaver-xscs-availability-set[0].id : null) : azurerm_availability_set.netweaver-app-availability-set[0].id
  vm_size                          = count.index < var.xscs_server_count ? var.xscs_vm_size : var.app_vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "disk-netweaver0${count.index + 1}-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.netweaver_image_uri != "" ? join(",", azurerm_image.netweaver-image.*.id) : ""
    publisher = var.netweaver_image_uri != "" ? "" : module.os_image_reference.publisher
    offer     = var.netweaver_image_uri != "" ? "" : module.os_image_reference.offer
    sku       = var.netweaver_image_uri != "" ? "" : module.os_image_reference.sku
    version   = var.netweaver_image_uri != "" ? "" : module.os_image_reference.version
  }

  os_profile {
    computer_name  = "vmnetweaver0${count.index + 1}"
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

module "netweaver_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = local.vm_count
  instance_ids         = azurerm_virtual_machine.netweaver.*.id
  user                 = var.common_variables["authorized_user"]
  private_key          = var.common_variables["private_key"]
  bastion_host         = var.bastion_host
  bastion_private_key  = var.common_variables["bastion_private_key"]
  public_ips           = local.provisioning_addresses
  dependencies         = [data.azurerm_public_ip.netweaver]
}
