# Availabilityset for the hana VMs

locals {
  bastion_enabled            = var.common_variables["bastion_enabled"]
  shared_storage_anf         = var.common_variables["hana"]["scale_out_enabled"] && var.common_variables["hana"]["scale_out_shared_storage_type"] == "anf" ? 1 : 0
  create_scale_out           = var.hana_count > 1 && var.common_variables["hana"]["scale_out_enabled"] ? 1 : 0
  create_ha_infra            = var.hana_count > 1 && var.common_variables["hana"]["ha_enabled"] ? 1 : 0
  sites                      = var.common_variables["hana"]["ha_enabled"] ? 2 : 1
  create_active_active_infra = local.create_ha_infra == 1 && var.common_variables["hana"]["cluster_vip_secondary"] != "" ? 1 : 0
  provisioning_addresses     = local.bastion_enabled ? data.azurerm_network_interface.hana.*.private_ip_address : data.azurerm_public_ip.hana.*.ip_address
  hana_lb_rules_ports = local.create_ha_infra == 1 ? toset([
    "3${var.hana_instance_number}13",
    "3${var.hana_instance_number}14",
    "3${var.hana_instance_number}40",
    "3${var.hana_instance_number}41",
    "3${var.hana_instance_number}42",
    "3${var.hana_instance_number}15",
    "3${var.hana_instance_number}17",
    "5${var.hana_instance_number}13" # S4HANA DB import checks sapctrl port
  ]) : toset([])

  hana_lb_rules_ports_secondary = local.create_active_active_infra == 1 ? local.hana_lb_rules_ports : toset([])

  hostname       = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
  hostnames_hana = [for h in range(var.hana_count) : format("%s%02d", local.hostname, h + 1)]
  hostname_mm    = format("%s%s", local.hostname, "mm")
  hostnames      = local.create_scale_out == 1 ? concat(local.hostnames_hana, [local.hostname_mm]) : local.hostnames_hana

  principal_ids = concat(azurerm_virtual_machine.hana.*.identity.0.principal_id, [module.hana_majority_maker.fence_principal_id])
  fence_scopes = flatten([
    for c in range(var.hana_count + local.create_scale_out) : [
      for n in local.hostnames : {
        count     = c
        node      = element(local.hostnames, c)
        principal = element(local.principal_ids, c)
        scope     = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Compute/virtualMachines/%s", data.azurerm_subscription.current.subscription_id, var.resource_group_name, n)
      }
    ]
  ])
}

data "azurerm_subscription" "current" {
}

resource "azurerm_availability_set" "hana-availability-set" {
  count                       = local.create_ha_infra
  name                        = "avset-hana"
  location                    = var.az_region
  resource_group_name         = var.resource_group_name
  managed                     = "true"
  platform_fault_domain_count = 2 + local.create_scale_out

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
  count           = local.create_ha_infra
  loadbalancer_id = azurerm_lb.hana-load-balancer[0].id
  name            = "lbbe-hana"
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
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.hana-load-balancer[0].id]
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
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.hana-load-balancer[0].id]
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
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.hana-load-balancer[0].id]
  probe_id                       = azurerm_lb_probe.hana-load-balancer[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

# hana network configuration

resource "azurerm_network_interface" "hana" {
  count                         = var.hana_count
  name                          = "nic-${var.name}${format("%02d", count.index + 1)}"
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
  name                    = "pip-${var.name}${format("%02d", count.index + 1)}"
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

# ANF volumes
resource "azurerm_netapp_volume" "hana-netapp-volume-data" {
  count = local.shared_storage_anf * local.sites

  lifecycle {
    prevent_destroy = false
  }

  name                = "${var.name}-netapp-volume-data-${count.index + 1}"
  location            = var.az_region
  resource_group_name = var.resource_group_name
  account_name        = var.anf_account_name
  pool_name           = var.anf_pool_name
  volume_path         = "${var.name}-data-${count.index + 1}"
  service_level       = var.anf_pool_service_level
  subnet_id           = var.network_subnet_netapp_id
  protocols           = ["NFSv4.1"]
  storage_quota_in_gb = var.hana_scale_out_anf_quota_data

  export_policy_rule {
    rule_index        = 1
    protocols_enabled = ["NFSv4.1"]
    allowed_clients   = ["0.0.0.0/0"]
    unix_read_write   = true
  }

  # Following section is only required if deploying a data protection volume (secondary)
  # to enable Cross-Region Replication feature
  # data_protection_replication {
  #   endpoint_type             = "dst"
  #   remote_volume_location    = azurerm_resource_group.example_primary.location
  #   remote_volume_resource_id = azurerm_netapp_volume.example_primary.id
  #   replication_frequency     = "10minutes"
  # }
}

resource "azurerm_netapp_volume" "hana-netapp-volume-log" {
  count = local.shared_storage_anf * local.sites

  lifecycle {
    prevent_destroy = false
  }

  name                = "${var.name}-netapp-volume-log-${count.index + 1}"
  location            = var.az_region
  resource_group_name = var.resource_group_name
  account_name        = "netapp-acc-${lower(var.common_variables["deployment_name"])}"
  pool_name           = "netapp-pool-${lower(var.common_variables["deployment_name"])}"
  volume_path         = "${var.name}-log-${count.index + 1}"
  service_level       = var.anf_pool_service_level
  subnet_id           = var.network_subnet_netapp_id
  protocols           = ["NFSv4.1"]
  storage_quota_in_gb = var.hana_scale_out_anf_quota_log

  export_policy_rule {
    rule_index        = 1
    protocols_enabled = ["NFSv4.1"]
    allowed_clients   = ["0.0.0.0/0"]
    unix_read_write   = true
  }

  # Following section is only required if deploying a data protection volume (secondary)
  # to enable Cross-Region Replication feature
  # data_protection_replication {
  #   endpoint_type             = "dst"
  #   remote_volume_location    = azurerm_resource_group.example_primary.location
  #   remote_volume_resource_id = azurerm_netapp_volume.example_primary.id
  #   replication_frequency     = "10minutes"
  # }
}

resource "azurerm_netapp_volume" "hana-netapp-volume-backup" {
  count = local.shared_storage_anf * local.sites

  lifecycle {
    prevent_destroy = false
  }

  name                = "${var.name}-netapp-volume-backup-${count.index + 1}"
  location            = var.az_region
  resource_group_name = var.resource_group_name
  account_name        = "netapp-acc-${lower(var.common_variables["deployment_name"])}"
  pool_name           = "netapp-pool-${lower(var.common_variables["deployment_name"])}"
  volume_path         = "${var.name}-backup-${count.index + 1}"
  service_level       = var.anf_pool_service_level
  subnet_id           = var.network_subnet_netapp_id
  protocols           = ["NFSv4.1"]
  storage_quota_in_gb = var.hana_scale_out_anf_quota_backup

  export_policy_rule {
    rule_index        = 1
    protocols_enabled = ["NFSv4.1"]
    allowed_clients   = ["0.0.0.0/0"]
    unix_read_write   = true
  }

  # Following section is only required if deploying a data protection volume (secondary)
  # to enable Cross-Region Replication feature
  # data_protection_replication {
  #   endpoint_type             = "dst"
  #   remote_volume_location    = azurerm_resource_group.example_primary.location
  #   remote_volume_resource_id = azurerm_netapp_volume.example_primary.id
  #   replication_frequency     = "10minutes"
  # }
}

resource "azurerm_netapp_volume" "hana-netapp-volume-shared" {
  count = local.shared_storage_anf * local.sites

  lifecycle {
    prevent_destroy = false
  }

  name                = "${var.name}-netapp-volume-shared-${count.index + 1}"
  location            = var.az_region
  resource_group_name = var.resource_group_name
  account_name        = "netapp-acc-${lower(var.common_variables["deployment_name"])}"
  pool_name           = "netapp-pool-${lower(var.common_variables["deployment_name"])}"
  volume_path         = "${var.name}-shared-${count.index + 1}"
  service_level       = var.anf_pool_service_level
  subnet_id           = var.network_subnet_netapp_id
  protocols           = ["NFSv4.1"]
  storage_quota_in_gb = var.hana_scale_out_anf_quota_shared

  export_policy_rule {
    rule_index        = 1
    protocols_enabled = ["NFSv4.1"]
    allowed_clients   = ["0.0.0.0/0"]
    unix_read_write   = true
  }

  # Following section is only required if deploying a data protection volume (secondary)
  # to enable Cross-Region Replication feature
  # data_protection_replication {
  #   endpoint_type             = "dst"
  #   remote_volume_location    = azurerm_resource_group.example_primary.location
  #   remote_volume_resource_id = azurerm_netapp_volume.example_primary.id
  #   replication_frequency     = "10minutes"
  # }
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
  name                             = "${var.name}${format("%02d", count.index + 1)}"
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [element(azurerm_network_interface.hana.*.id, count.index)]
  availability_set_id              = var.common_variables["hana"]["ha_enabled"] ? azurerm_availability_set.hana-availability-set[0].id : null
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "disk-${var.name}${format("%02d", count.index + 1)}-Os"
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
      name                      = "disk-${var.name}${format("%02d", count.index + 1)}-Data${format("%02d", storage_data_disk.value.index + 1)}"
      managed_disk_type         = element(local.disks_type, storage_data_disk.value.index)
      create_option             = "Empty"
      lun                       = storage_data_disk.value.index
      disk_size_gb              = element(local.disks_size, storage_data_disk.value.index)
      caching                   = element(local.disks_caching, storage_data_disk.value.index)
      write_accelerator_enabled = element(local.disks_writeaccelerator, storage_data_disk.value.index)
    }
  }

  os_profile {
    computer_name  = element(local.hostnames_hana, count.index)
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

  identity {
    type = "SystemAssigned"
  }

  tags = {
    workspace = var.common_variables["deployment_name"]
  }
}

resource "azurerm_role_definition" "fence" {
  count = var.common_variables["hana"]["ha_enabled"] && var.common_variables["hana"]["fencing_mechanism"] == "native" ? 1 : 0
  name  = "role-fence-${local.hostname}"
  # It is recommended to use the first entry of the assignable_scopes.
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition#scope
  scope = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Compute/virtualMachines/%s%02d", data.azurerm_subscription.current.subscription_id, var.resource_group_name, local.hostname, count.index + 1)

  permissions {
    actions = [
      "Microsoft.Compute/*/read",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/start/action"
    ]
    not_actions = []
  }

  assignable_scopes = [
    for h in local.hostnames : format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Compute/virtualMachines/%s", data.azurerm_subscription.current.subscription_id, var.resource_group_name, h)
  ]
}

resource "azurerm_role_assignment" "host" {
  for_each           = { for r in local.fence_scopes : "${r.node}_${r.scope}" => r if var.common_variables["hana"]["ha_enabled"] && var.common_variables["hana"]["fencing_mechanism"] == "native" }
  scope              = each.value.scope
  role_definition_id = element(azurerm_role_definition.fence.*.role_definition_resource_id, 0)
  principal_id       = each.value.principal
}

module "hana_majority_maker" {
  source                        = "../majority_maker_node"
  node_count                    = local.create_scale_out
  name                          = local.hostname
  common_variables              = var.common_variables
  bastion_host                  = var.bastion_host
  az_region                     = var.az_region
  vm_size                       = var.majority_maker_vm_size
  hana_count                    = var.hana_count
  majority_maker_ip             = var.majority_maker_ip
  host_ips                      = var.host_ips
  resource_group_name           = var.resource_group_name
  network_subnet_id             = var.network_subnet_id
  storage_account               = var.storage_account
  storage_account_name          = var.storage_account_name
  storage_account_key           = var.storage_account_key
  enable_accelerated_networking = var.enable_accelerated_networking
  sles4sap_uri                  = var.sles4sap_uri
  cluster_ssh_pub               = var.cluster_ssh_pub
  cluster_ssh_key               = var.cluster_ssh_key
  os_image                      = var.os_image
  iscsi_srv_ip                  = var.iscsi_srv_ip
}

module "hana_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.hana_count
  instance_ids        = azurerm_virtual_machine.hana.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  dependencies        = [data.azurerm_public_ip.hana]
}
