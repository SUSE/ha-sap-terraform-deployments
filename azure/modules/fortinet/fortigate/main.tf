locals {
  public_ips = {
    "pip-fgt-v" = {
      name                = "pip-fgt-v"
      location            = var.az_region
      resource_group_name = var.resource_group_name
      allocation_method   = "Static"
      sku                 = "Standard"
    },
    "pip-fgt-a" = {
      name                = "pip-fgt-a"
      location            = var.az_region
      resource_group_name = var.resource_group_name
      allocation_method   = "Static"
      sku                 = "Standard"
    },
    "pip-fgt-b" = {
      name                = "pip-fgt-b"
      location            = var.az_region
      resource_group_name = var.resource_group_name
      allocation_method   = "Static"
      sku                 = "Standard"
    },
    "pip-bastion-lb-fe" = {
      name                = "pip-bastion-lb-fe"
      location            = var.az_region
      resource_group_name = var.resource_group_name
      allocation_method   = "Static"
      sku                 = "Standard"
    }
  }

  network_interfaces = {
    "nic-fortigate_a_1" = {
      name                          = "nic-fortigate_a_1"
      location                      = var.az_region
      resource_group_name           = var.resource_group_name
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = var.snet_ids["external-fgt"]
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(var.snet_address_ranges["external-fgt"], 6)
          public_ip_address_id          = null
        }
      ]
    },
    "nic-fortigate_a_2" = {
      name                          = "nic-fortigate_a_2"
      location                      = var.az_region
      resource_group_name           = var.resource_group_name
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = var.snet_ids["internal-fgt"]
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(var.snet_address_ranges["internal-fgt"], 6)
          public_ip_address_id          = null
        }
      ]
    },
    "nic-fortigate_a_3" = {
      name                          = "nic-fortigate_a_3"
      location                      = var.az_region
      resource_group_name           = var.resource_group_name
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = var.snet_ids["hasync-ftnt"]
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(var.snet_address_ranges["hasync-ftnt"], 6)
          public_ip_address_id          = null
        }
      ]
    },
    "nic-fortigate_a_4" = {
      name                          = "nic-fortigate_a_4"
      location                      = var.az_region
      resource_group_name           = var.resource_group_name
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = var.snet_ids["mgmt-ftnt"]
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(var.snet_address_ranges["mgmt-ftnt"], 6)
          public_ip_address_id          = azurerm_public_ip.public_ip["pip-fgt-a"].id
        }
      ]
    },
    "nic-fortigate_b_1" = {
      name                          = "nic-fortigate_b_1"
      location                      = var.az_region
      resource_group_name           = var.resource_group_name
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = var.snet_ids["external-fgt"]
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(var.snet_address_ranges["external-fgt"], 7)
          public_ip_address_id          = null
        }
      ]
    },
    "nic-fortigate_b_2" = {
      name                          = "nic-fortigate_b_2"
      location                      = var.az_region
      resource_group_name           = var.resource_group_name
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = var.snet_ids["internal-fgt"]
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(var.snet_address_ranges["internal-fgt"], 7)
          public_ip_address_id          = null
        }
      ]
    },
    "nic-fortigate_b_3" = {
      name                          = "nic-fortigate_b_3"
      location                      = var.az_region
      resource_group_name           = var.resource_group_name
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = var.snet_ids["hasync-ftnt"]
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(var.snet_address_ranges["hasync-ftnt"], 7)
          public_ip_address_id          = null
        }
      ]
    },
    "nic-fortigate_b_4" = {
      name                          = "nic-fortigate_b_4"
      location                      = var.az_region
      resource_group_name           = var.resource_group_name
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = var.snet_ids["mgmt-ftnt"]
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(var.snet_address_ranges["mgmt-ftnt"], 7)
          public_ip_address_id          = azurerm_public_ip.public_ip["pip-fgt-b"].id
        }
      ]
    }
  }

  route_tables = {
    "rt-hub" = {
      name                = "rt-hub"
      location            = var.az_region
      resource_group_name = var.resource_group_name
    },
    "rt-spoke" = {
      name                = "rt-spoke"
      location            = var.az_region
      resource_group_name = var.resource_group_name
    },
  }

  routes = {
    "r-default-hub" = {
      resource_group_name    = var.resource_group_name
      name                   = "r-default-hub"
      address_prefix         = "0.0.0.0/0"
      next_hop_in_ip_address = azurerm_lb.lb["lb-fgt-internal"].private_ip_address
      next_hop_type          = "VirtualAppliance"
      route_table_name       = azurerm_route_table.route_table["rt-hub"].name
    },
    "r-default-spoke" = {
      resource_group_name    = var.resource_group_name
      name                   = "r-default-spoke"
      address_prefix         = "0.0.0.0/0"
      next_hop_in_ip_address = azurerm_lb.lb["lb-fgt-internal"].private_ip_address
      next_hop_type          = "VirtualAppliance"
      route_table_name       = azurerm_route_table.route_table["rt-spoke"].name
    },
    "r-spoke" = {
      resource_group_name    = var.resource_group_name
      name                   = "r-spoke"
      address_prefix         = var.vnet_spoke_address_range
      next_hop_in_ip_address = azurerm_lb.lb["lb-fgt-internal"].private_ip_address
      next_hop_type          = "VirtualAppliance"
      route_table_name       = azurerm_route_table.route_table["rt-hub"].name
    },
    "r-hub" = {
      resource_group_name    = var.resource_group_name
      name                   = "r-hub"
      address_prefix         = var.vnet_address_range
      next_hop_in_ip_address = azurerm_lb.lb["lb-fgt-internal"].private_ip_address
      next_hop_type          = "VirtualAppliance"
      route_table_name       = azurerm_route_table.route_table["rt-spoke"].name
    },
      "r-mgmt" = {
      resource_group_name    = var.resource_group_name
      name                   = "r-mgmt"
      address_prefix         = var.snet_address_ranges["mgmt"]
      next_hop_in_ip_address = azurerm_lb.lb["lb-fgt-internal"].private_ip_address
      next_hop_type          = "VirtualAppliance"
      route_table_name       = azurerm_route_table.route_table["rt-hub"].name
    },
    "r-mon" = {
      resource_group_name    = var.resource_group_name
      name                   = "r-mon"
      address_prefix         = var.snet_address_ranges["mon"]
      next_hop_in_ip_address = azurerm_lb.lb["lb-fgt-internal"].private_ip_address
      next_hop_type          = "VirtualAppliance"
      route_table_name       = azurerm_route_table.route_table["rt-hub"].name
    }
  }

  subnet_route_table_associations = {
    "hub-external-fadc" = {
      subnet_id      = var.snet_ids["external-fadc"]
      route_table_id = azurerm_route_table.route_table["rt-hub"].id
    },
    "hub-mgmt" = {
      subnet_id      = var.snet_ids["mgmt"]
      route_table_id = azurerm_route_table.route_table["rt-hub"].id
    },
    "hub-mon" = {
      subnet_id      = var.snet_ids["mon"]
      route_table_id = azurerm_route_table.route_table["rt-hub"].id
    },
    "spoke-sap-1-workload" = {
      subnet_id      = var.snet_ids["spoke-sap-1-workload"]
      route_table_id = azurerm_route_table.route_table["rt-spoke"].id
    }
  }
  network_security_groups = {
    "nsg-fortigate" = {
      name                = "nsg-fortigate"
      location            = var.az_region
      resource_group_name = var.resource_group_name
    }
  }

  network_security_rules = {
    "nsg-fortigate-inbound-rule" = {
      name                        = "nsg-fortigate-inbound-rule"
      resource_group_name         = var.resource_group_name
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-fortigate"].name
      priority                    = "100"
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
    },
    "nsg-fortigate-outbound-rule" = {
      name                        = "nsg-fortigate-outbound-rule"
      resource_group_name         = var.resource_group_name
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-fortigate"].name
      priority                    = "101"
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
    }
  }

  network_security_group_associations = {
    "nic-fortigate_a_1" = {
      network_interface_id      = azurerm_network_interface.network_interface["nic-fortigate_a_1"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-fortigate"].id
    },
    "nic-fortigate_a_2" = {
      network_interface_id      = azurerm_network_interface.network_interface["nic-fortigate_a_2"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-fortigate"].id
    },
    "nic-fortigate_a_3" = {
      network_interface_id      = azurerm_network_interface.network_interface["nic-fortigate_a_3"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-fortigate"].id
    },
    "nic-fortigate_a_4" = {
      network_interface_id      = azurerm_network_interface.network_interface["nic-fortigate_a_4"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-fortigate"].id
    },
    "nic-fortigate_b_1" = {
      network_interface_id      = azurerm_network_interface.network_interface["nic-fortigate_b_1"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-fortigate"].id
    },
    "nic-fortigate_b_2" = {
      network_interface_id      = azurerm_network_interface.network_interface["nic-fortigate_b_2"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-fortigate"].id
    },
    "nic-fortigate_b_3" = {
      network_interface_id      = azurerm_network_interface.network_interface["nic-fortigate_b_3"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-fortigate"].id
    },
    "nic-fortigate_b_4" = {
      network_interface_id      = azurerm_network_interface.network_interface["nic-fortigate_b_4"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-fortigate"].id
    }
  }

  lbs = {
    "lb-fgt-external" = {
      name                = "lb-fgt-external"
      location            = var.az_region
      resource_group_name = var.resource_group_name
      sku                 = "standard"

      frontend_ip_configurations = [
        {
          name                 = "lb-fgt-external-fe-ip-01"
          public_ip_address_id = azurerm_public_ip.public_ip["pip-fgt-v"].id
        },
        {
          name                 = "lb-fgt-external-fe-ip-02"
          public_ip_address_id = azurerm_public_ip.public_ip["pip-bastion-lb-fe"].id
        },
      ]
    },
    "lb-fgt-internal" = {
      name                = "lb-fgt-internal"
      location            = var.az_region
      resource_group_name = var.resource_group_name
      sku                 = "standard"

      frontend_ip_configurations = [
        {
          name                          = "lb-fgt-internal-fe-ip-01"
          subnet_id                     = var.snet_ids["internal-fgt"]
          private_ip_address            = cidrhost(var.snet_address_ranges["internal-fgt"], 4)
          private_ip_address_allocation = "Static"
          private_ip_address_version    = "IPv4"
        }
      ]
    }
  }

  lb_backend_address_pools = {
    "lb-fgt-external-be-pool-01" = {
      name                = "lb-fgt-external-be-pool-01"
      resource_group_name = var.resource_group_name
      loadbalancer_id     = azurerm_lb.lb["lb-fgt-external"].id
    },
    "lb-fgt-internal-be-pool-01" = {
      name                = "lb-fgt-internal-be-pool-01"
      resource_group_name = var.resource_group_name
      loadbalancer_id     = azurerm_lb.lb["lb-fgt-internal"].id
    }
  }

  lb_probes = {
    "lb-fgt-external-probe" = {
      name                = "lb-fgt-external-probe"
      resource_group_name = var.resource_group_name
      loadbalancer_id     = azurerm_lb.lb["lb-fgt-external"].id
      port                = "8008"
      protocol            = "Tcp"
      interval_in_seconds = "5"
    },
    "lb-fgt-internal-probe" = {
      name                = "lb-fgt-internal-probe"
      resource_group_name = var.resource_group_name
      loadbalancer_id     = azurerm_lb.lb["lb-fgt-internal"].id
      port                = "8008"
      protocol            = "Tcp"
      interval_in_seconds = "5"
    }
  }

  lb_rules = {
    "lb-fgt-external-rule-443" = {
      name                           = "lb-fgt-external-rule-443"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = azurerm_lb.lb["lb-fgt-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "443"
      backend_port                   = "443"
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
      probe_id                       = azurerm_lb_probe.lb_probe["lb-fgt-external-probe"].id
      backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-external-be-pool-01"].id
      enable_floating_ip             = true
      disable_outbound_snat          = true
    },
    "lb-fgt-external-rule-80" = {
      name                           = "lb-fgt-external-rule-80"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = azurerm_lb.lb["lb-fgt-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "80"
      backend_port                   = "80"
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
      probe_id                       = azurerm_lb_probe.lb_probe["lb-fgt-external-probe"].id
      backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-external-be-pool-01"].id
      enable_floating_ip             = true
      disable_outbound_snat          = true
    },
    "lb-fgt-external-rule-22" = {
      name                           = "lb-fgt-external-rule-22"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = azurerm_lb.lb["lb-fgt-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "22"
      backend_port                   = "22"
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-02"
      probe_id                       = azurerm_lb_probe.lb_probe["lb-fgt-external-probe"].id
      backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-external-be-pool-01"].id
      enable_floating_ip             = true
      disable_outbound_snat          = true
    },
    "lb-fgt-external-rule-10551" = {
      name                           = "lb-fgt-external-rule-10551"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = azurerm_lb.lb["lb-fgt-external"].id
      protocol                       = "Udp"
      frontend_port                  = "10551"
      backend_port                   = "10551"
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
      probe_id                       = azurerm_lb_probe.lb_probe["lb-fgt-external-probe"].id
      backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-external-be-pool-01"].id
      enable_floating_ip             = true
      disable_outbound_snat          = true
    },
    "lb-fgt-internal-rule-all" = {
      name                           = "lb-fgt-internal-rule-all"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = azurerm_lb.lb["lb-fgt-internal"].id
      protocol                       = "All"
      frontend_port                  = "0"
      backend_port                   = "0"
      frontend_ip_configuration_name = "lb-fgt-internal-fe-ip-01"
      probe_id                       = azurerm_lb_probe.lb_probe["lb-fgt-internal-probe"].id
      backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-internal-be-pool-01"].id
      enable_floating_ip             = true
      disable_outbound_snat          = true
    },
    "lb-fgt-external-rule-fadc-a" = {
      name                           = "lb-fgt-external-rule-fadc-a"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = azurerm_lb.lb["lb-fgt-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "41443"
      backend_port                   = "41443"
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
      probe_id                       = azurerm_lb_probe.lb_probe["lb-fgt-external-probe"].id
      backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-external-be-pool-01"].id
      enable_floating_ip             = false
      disable_outbound_snat          = true
    },
    "lb-fgt-external-rule-fadc-b" = {
      name                           = "lb-fgt-external-rule-fadc-b"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = azurerm_lb.lb["lb-fgt-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "51443"
      backend_port                   = "51443"
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
      probe_id                       = azurerm_lb_probe.lb_probe["lb-fgt-external-probe"].id
      backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-external-be-pool-01"].id
      enable_floating_ip             = false
      disable_outbound_snat          = true
    }
  }

  lb_outbound_rules = {
    "lb-fgt-external-rule-outboundall" = {
      name                           = "lb-fgt-external-rule-outboundall"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = azurerm_lb.lb["lb-fgt-external"].id
      protocol                       = "All"
      backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-external-be-pool-01"].id
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
    }
  }

  network_interface_backend_address_pool_associations = {
    "nic-fortigate_a_1" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_a_1"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-external-be-pool-01"].id
    },
    "nic-fortigate_b_1" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_b_1"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-external-be-pool-01"].id
    },
    "nic-fortigate_a_2" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_a_2"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-internal-be-pool-01"].id
    },
    "nic-fortigate_b_2" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_b_2"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fgt-internal-be-pool-01"].id
    }
  }

  lb_nat_rules = {
    "lb-nat-rule-fgt-a-https-mgmt" = {
      name                           = "lb-nat-rule-fgt-a-https-mgmt"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = "lb-fgt-external"
      protocol                       = "Tcp"
      frontend_port                  = 40443
      backend_port                   = 443
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
    },
    "lb-nat-rule-fgt-b-https-mgmt" = {
      name                           = "lb-nat-rule-fgt-b-https-mgmt"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = "lb-fgt-external"
      protocol                       = "Tcp"
      frontend_port                  = 50443
      backend_port                   = 443
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
      }, "lb-nat-rule-fgt-a-ssh-mgmt" = {
      name                           = "lb-nat-rule-fgt-a-ssh-mgmt"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = "lb-fgt-external"
      protocol                       = "Tcp"
      frontend_port                  = 40022
      backend_port                   = 22
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
    },
    "lb-nat-rule-fgt-b-ssh-mgmt" = {
      name                           = "lb-nat-rule-fgt-b-ssh-mgmt"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = "lb-fgt-external"
      protocol                       = "Tcp"
      frontend_port                  = 50022
      backend_port                   = 22
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
    }
  }

  network_interface_nat_rule_associations = {
    "lb-nat-rule-fgt-a-https-mgmt-association" = {
      network_interface_id  = "nic-fortigate_a_4"
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = "lb-nat-rule-fgt-a-https-mgmt"
    },
    "lb-nat-rule-fgt-b-https-mgmt-association" = {
      network_interface_id  = "nic-fortigate_b_4"
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = "lb-nat-rule-fgt-b-https-mgmt"
    },
    "lb-nat-rule-fgt-a-ssh-mgmt-association" = {
      network_interface_id  = "nic-fortigate_a_4"
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = "lb-nat-rule-fgt-a-ssh-mgmt"
    },
    "lb-nat-rule-fgt-b-ssh-mgmt-association" = {
      network_interface_id  = "nic-fortigate_b_4"
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = "lb-nat-rule-fgt-b-ssh-mgmt"
    }
  }

  availability_sets = {
    "as-fortigate" = {
      name                = "as-fortigate"
      location            = var.az_region
      resource_group_name = var.resource_group_name
    }
  }

  virtual_machines = {
    "vm-fgt-a" = {
      name                = "vm-fgt-a"
      location            = var.az_region
      resource_group_name = var.resource_group_name

      config_template = "fgt-config.conf"
      identity        = "SystemAssigned"

      network_interface_ids        = [for nic in ["nic-fortigate_a_1", "nic-fortigate_a_2", "nic-fortigate_a_3", "nic-fortigate_a_4"] : azurerm_network_interface.network_interface[nic].id]
      primary_network_interface_id = azurerm_network_interface.network_interface["nic-fortigate_a_1"].id

      publisher = var.vm_publisher
      offer     = var.vm_offer
      plan      = var.vm_sku
      version   = var.vm_version
      vm_size   = var.vm_size

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true

      storage_os_disk_name              = "disk-fgt-a-os"
      storage_os_disk_managed_disk_type = "Premium_LRS"
      storage_os_disk_create_option     = "FromImage"
      storage_os_disk_caching           = "ReadWrite"

      storage_data_disk_name              = "disk-vm-fgt-a-data"
      storage_data_disk_managed_disk_type = "Premium_LRS"
      storage_data_disk_create_option     = "Empty"
      storage_data_disk_disk_size_gb      = "30"
      storage_data_disk_lun               = "0"

      os_profile_computer_name  = "vm-fgt-a"
      os_profile_admin_username = var.vm_username
      os_profile_admin_password = var.vm_password

      zone = "1"

      availability_set_id = azurerm_availability_set.availability_set["as-fortigate"].id

      fgt_license_file    = "${var.fortinet_licenses["license_a"]}"
      fgt_ha_priority     = "255"
      fgt_admins_port     = "443"
      fgt_license_type    = var.vm_license
      fgt_port1_ip        = cidrhost(var.snet_address_ranges["external-fgt"], 6)
      fgt_port1_mask      = cidrnetmask(var.snet_address_ranges["external-fgt"])
      fgt_port1_gateway   = cidrhost(var.snet_address_ranges["external-fgt"], 1)
      fgt_port2_ip        = cidrhost(var.snet_address_ranges["internal-fgt"], 6)
      fgt_port2_mask      = cidrnetmask(var.snet_address_ranges["internal-fgt"])
      fgt_port2_gateway   = cidrhost(var.snet_address_ranges["internal-fgt"], 1)
      fgt_port3_ip        = cidrhost(var.snet_address_ranges["hasync-ftnt"], 6)
      fgt_port3_peerip    = cidrhost(var.snet_address_ranges["hasync-ftnt"], 7)
      fgt_port3_mask      = cidrnetmask(var.snet_address_ranges["hasync-ftnt"])
      fgt_port4_ip        = cidrhost(var.snet_address_ranges["mgmt-ftnt"], 6)
      fgt_port4_mask      = cidrnetmask(var.snet_address_ranges["mgmt-ftnt"])
      fgt_port4_gateway   = cidrhost(var.snet_address_ranges["mgmt-ftnt"], 1)
      fgt_vnet            = var.vnet_address_range
      bastion_frontend_ip = azurerm_public_ip.public_ip["pip-bastion-lb-fe"].ip_address
      bastion_private_ip  = var.bastion_private_ip
      spoke_address_range = var.vnet_spoke_address_range
      fadc_mgmt_a         = cidrhost(var.snet_address_ranges["internal-fadc"], 6)
      fadc_mgmt_b         = cidrhost(var.snet_address_ranges["internal-fadc"], 7)      
    },
    "vm-fgt-b" = {
      name                = "vm-fgt-b"
      location            = var.az_region
      resource_group_name = var.resource_group_name

      config_template = "fgt-config.conf"
      identity        = "SystemAssigned"

      network_interface_ids        = [for nic in ["nic-fortigate_b_1", "nic-fortigate_b_2", "nic-fortigate_b_3", "nic-fortigate_b_4"] : azurerm_network_interface.network_interface[nic].id]
      primary_network_interface_id = azurerm_network_interface.network_interface["nic-fortigate_b_1"].id

      publisher = var.vm_publisher
      offer     = var.vm_offer
      plan      = var.vm_sku
      version   = var.vm_version
      vm_size   = var.vm_size

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true

      storage_os_disk_name              = "disk-fgt-b-os"
      storage_os_disk_managed_disk_type = "Premium_LRS"
      storage_os_disk_create_option     = "FromImage"
      storage_os_disk_caching           = "ReadWrite"

      storage_data_disk_name              = "disk-vm-fgt-b-data"
      storage_data_disk_managed_disk_type = "Premium_LRS"
      storage_data_disk_create_option     = "Empty"
      storage_data_disk_disk_size_gb      = "30"
      storage_data_disk_lun               = "0"

      os_profile_computer_name  = "vm-fgt-b"
      os_profile_admin_username = var.vm_username
      os_profile_admin_password = var.vm_password

      zone = "1"

      availability_set_id = azurerm_availability_set.availability_set["as-fortigate"].id

      fgt_license_file    = "${var.fortinet_licenses["license_b"]}"
      fgt_ha_priority     = "1"
      fgt_admins_port     = "443"
      fgt_license_type    = var.vm_license
      fgt_port1_ip        = cidrhost(var.snet_address_ranges["external-fgt"], 7)
      fgt_port1_mask      = cidrnetmask(var.snet_address_ranges["external-fgt"])
      fgt_port1_gateway   = cidrhost(var.snet_address_ranges["external-fgt"], 1)
      fgt_port2_ip        = cidrhost(var.snet_address_ranges["internal-fgt"], 7)
      fgt_port2_mask      = cidrnetmask(var.snet_address_ranges["internal-fgt"])
      fgt_port2_gateway   = cidrhost(var.snet_address_ranges["internal-fgt"], 1)
      fgt_port3_ip        = cidrhost(var.snet_address_ranges["hasync-ftnt"], 7)
      fgt_port3_peerip    = cidrhost(var.snet_address_ranges["hasync-ftnt"], 6)
      fgt_port3_mask      = cidrnetmask(var.snet_address_ranges["hasync-ftnt"])
      fgt_port4_ip        = cidrhost(var.snet_address_ranges["mgmt-ftnt"], 7)
      fgt_port4_mask      = cidrnetmask(var.snet_address_ranges["mgmt-ftnt"])
      fgt_port4_gateway   = cidrhost(var.snet_address_ranges["mgmt-ftnt"], 1)
      fgt_vnet            = var.vnet_address_range
      bastion_frontend_ip = azurerm_public_ip.public_ip["pip-bastion-lb-fe"].ip_address
      bastion_private_ip  = var.bastion_private_ip
      spoke_address_range = var.vnet_spoke_address_range
      fadc_mgmt_a         = cidrhost(var.snet_address_ranges["internal-fadc"], 6)
      fadc_mgmt_b         = cidrhost(var.snet_address_ranges["internal-fadc"], 7)      

    }
  }

  role_assignments = {
    "ra-fgt-a" = {
      scope                = var.resource_group_id
      role_definition_name = "Reader"
      principal_id = azurerm_virtual_machine.virtual_machine["vm-fgt-a"].identity[0].principal_id
    },
    "ra-fgt-b" = {
      scope                = var.resource_group_id
      role_definition_name = "Reader"
      principal_id = azurerm_virtual_machine.virtual_machine["vm-fgt-b"].identity[0].principal_id
    }
  }

  fgt_configs = {
    "fgt-config-a" = {
      name   = "fgt-config-a"
      config = data.template_file.custom_data["vm-fgt-a"].rendered
    },
    "fgt-config-b" = {
      name   = "fgt-config-b"
      config = data.template_file.custom_data["vm-fgt-b"].rendered
    }
  }
}

resource "local_file" "file" {

  for_each = local.fgt_configs

  filename = "${path.module}/${each.value.name}.txt"
  content  = each.value.config
}
resource "azurerm_public_ip" "public_ip" {

  for_each = local.public_ips

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
}
resource "azurerm_network_interface" "network_interface" {

  for_each = local.network_interfaces

  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = each.value.resource_group_name
  enable_ip_forwarding          = each.value.enable_ip_forwarding
  enable_accelerated_networking = each.value.enable_accelerated_networking

  dynamic "ip_configuration" {

    for_each = each.value.ip_configurations
    content {
      name                          = ip_configuration.value.name
      primary                       = lookup(ip_configuration.value, "primary", false)
      subnet_id                     = ip_configuration.value.subnet_id
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
      private_ip_address            = ip_configuration.value.private_ip_address
      public_ip_address_id          = ip_configuration.value.public_ip_address_id
    }
  }
}

resource "azurerm_route_table" "route_table" {

  for_each = local.route_tables

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_route" "route" {

  for_each = local.routes

  name                   = each.value.name
  resource_group_name    = each.value.resource_group_name
  route_table_name       = each.value.route_table_name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

resource "azurerm_subnet_route_table_association" "subnet_route_table_association" {

  for_each = local.subnet_route_table_associations

  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}

resource "azurerm_network_security_group" "network_security_group" {

  for_each = local.network_security_groups

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  depends_on = [
    azurerm_network_interface.network_interface
  ]
}

resource "azurerm_network_security_rule" "network_security_rule" {

  for_each = local.network_security_rules

  name                        = each.value.name
  network_security_group_name = each.value.network_security_group_name
  resource_group_name         = each.value.resource_group_name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
}

resource "azurerm_network_interface_security_group_association" "network_interface_security_group_association" {

  for_each = local.network_security_group_associations

  network_interface_id      = each.value.network_interface_id
  network_security_group_id = each.value.network_security_group_id

  depends_on = [
    azurerm_network_interface.network_interface
  ]
}

resource "azurerm_lb" "lb" {

  for_each = local.lbs

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku

  dynamic "frontend_ip_configuration" {

    for_each = [
      for fe_ip in each.value.frontend_ip_configurations : fe_ip
      if lookup(fe_ip, "public_ip_address_id", null) != null
    ]
    content {
      name                 = frontend_ip_configuration.value.name
      public_ip_address_id = frontend_ip_configuration.value.public_ip_address_id
    }
  }
  dynamic "frontend_ip_configuration" {

    for_each = [
      for fe_ip in each.value.frontend_ip_configurations : fe_ip
      if lookup(fe_ip, "private_ip_address", null) != null
    ]
    content {
      name                          = frontend_ip_configuration.value.name
      subnet_id                     = frontend_ip_configuration.value.subnet_id
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
      private_ip_address_version    = frontend_ip_configuration.value.private_ip_address_version
    }
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_address_pool" {

  for_each = local.lb_backend_address_pools

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  loadbalancer_id     = each.value.loadbalancer_id
}

resource "azurerm_lb_probe" "lb_probe" {

  for_each = local.lb_probes

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  loadbalancer_id     = each.value.loadbalancer_id
  port                = each.value.port
  protocol            = each.value.protocol
  interval_in_seconds = each.value.interval_in_seconds
}

resource "azurerm_lb_rule" "lb_rule" {

  for_each = local.lb_rules

  name                           = each.value.name
  resource_group_name            = each.value.resource_group_name
  loadbalancer_id                = each.value.loadbalancer_id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  probe_id                       = each.value.probe_id
  backend_address_pool_id        = each.value.backend_address_pool_id
  enable_floating_ip             = each.value.enable_floating_ip
  disable_outbound_snat          = each.value.disable_outbound_snat
}

resource "azurerm_lb_outbound_rule" "lb_outbound_rule" {

  for_each = local.lb_outbound_rules

  name                    = each.value.name
  resource_group_name     = each.value.resource_group_name
  loadbalancer_id         = each.value.loadbalancer_id
  protocol                = each.value.protocol
  backend_address_pool_id = each.value.backend_address_pool_id
  frontend_ip_configuration {
    name = each.value.frontend_ip_configuration_name
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "network_interface_backend_address_pool_association" {

  for_each = local.network_interface_backend_address_pool_associations

  network_interface_id    = each.value.network_interface_id
  ip_configuration_name   = each.value.ip_configuration_name
  backend_address_pool_id = each.value.backend_address_pool_id

  depends_on = [
    azurerm_network_interface.network_interface,
    azurerm_virtual_machine.virtual_machine
  ]
}

resource "azurerm_lb_nat_rule" "lb_nat_rule" {

  for_each = local.lb_nat_rules

  name                           = each.value.name
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb[each.value.loadbalancer_id].id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
}

resource "azurerm_network_interface_nat_rule_association" "network_interface_nat_rule_association" {

  for_each = local.network_interface_nat_rule_associations

  network_interface_id  = azurerm_network_interface.network_interface[each.value.network_interface_id].id
  ip_configuration_name = each.value.ip_configuration_name
  nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule[each.value.nat_rule_id].id
}

resource "azurerm_availability_set" "availability_set" {

  for_each = local.availability_sets

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_virtual_machine" "virtual_machine" {

  for_each = local.virtual_machines

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  network_interface_ids        = each.value.network_interface_ids
  primary_network_interface_id = each.value.primary_network_interface_id
  vm_size                      = each.value.vm_size

  delete_os_disk_on_termination    = each.value.delete_os_disk_on_termination
  delete_data_disks_on_termination = each.value.delete_data_disks_on_termination

  boot_diagnostics {
    enabled     = true
    storage_uri = var.storage_account
  }

  identity {
    type = each.value.identity
  }

  storage_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.plan
    version   = each.value.version
  }

  plan {
    publisher = each.value.publisher
    product   = each.value.offer
    name      = each.value.plan
  }

  storage_os_disk {
    name              = each.value.storage_os_disk_name
    managed_disk_type = each.value.storage_os_disk_managed_disk_type
    create_option     = each.value.storage_os_disk_create_option
    caching           = each.value.storage_os_disk_caching
  }

  storage_data_disk {
    name              = each.value.storage_data_disk_name
    managed_disk_type = each.value.storage_data_disk_managed_disk_type
    create_option     = each.value.storage_data_disk_create_option
    disk_size_gb      = each.value.storage_data_disk_disk_size_gb
    lun               = each.value.storage_data_disk_lun
  }
  os_profile {
    computer_name  = each.value.os_profile_computer_name
    admin_username = each.value.os_profile_admin_username
    admin_password = each.value.os_profile_admin_password
    custom_data    = data.template_file.custom_data[each.key].rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  #zones = [each.value.zone]

  availability_set_id = each.value.availability_set_id

  depends_on = [
    azurerm_network_interface.network_interface
  ]
}

data "template_file" "custom_data" {

  for_each = local.virtual_machines

  template = file("${path.module}/${each.value.config_template}")
  vars = {
    fgt_id              = each.value.name
    fgt_license_file    = each.value.fgt_license_file
    fgt_ha_priority     = each.value.fgt_ha_priority
    fgt_admins_port     = each.value.fgt_admins_port
    fgt_license_type    = each.value.fgt_license_type
    fgt_port1_ip        = each.value.fgt_port1_ip
    fgt_port1_mask      = each.value.fgt_port1_mask
    fgt_port1_gateway   = each.value.fgt_port1_gateway
    fgt_port2_ip        = each.value.fgt_port2_ip
    fgt_port2_mask      = each.value.fgt_port2_mask
    fgt_port2_gateway   = each.value.fgt_port2_gateway
    fgt_port3_ip        = each.value.fgt_port3_ip
    fgt_port3_mask      = each.value.fgt_port3_mask
    fgt_port3_peerip    = each.value.fgt_port3_peerip
    fgt_port4_ip        = each.value.fgt_port4_ip
    fgt_port4_mask      = each.value.fgt_port4_mask
    fgt_port4_gateway   = each.value.fgt_port4_gateway
    fgt_vnet            = each.value.fgt_vnet
    bastion_frontend_ip = each.value.bastion_frontend_ip
    bastion_private_ip  = each.value.bastion_private_ip
    spoke_address_range = each.value.spoke_address_range
    fadc_mgmt_a         = each.value.fadc_mgmt_a
    fadc_mgmt_b         = each.value.fadc_mgmt_b
  }
}

resource "azurerm_role_assignment" "role_assignment" {

  for_each = local.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id

  depends_on = [
    azurerm_virtual_machine.virtual_machine
  ]
}