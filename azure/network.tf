# Launch SLES-HAE of SLES4SAP cluster nodes

# Private IP addresses for the cluster nodes

# Network resources: Virtual Network, Subnet
resource "azurerm_virtual_network" "mynet" {
  name                = "mynet"
  address_space       = ["10.74.0.0/16"]
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_subnet" "mysubnet" {
  name                 = "mysubnet"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.mynet.name
  address_prefix       = "10.74.1.0/24"
}

resource "azurerm_subnet_network_security_group_association" "mysubnet" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.mysecgroup.id
}

resource "azurerm_subnet_route_table_association" "mysubnet" {
  subnet_id      = azurerm_subnet.mysubnet.id
  route_table_id = azurerm_route_table.myroutes.id
}

# Load Balancer

resource "azurerm_lb" "mylb" {
  name                = "my-load-balancer"
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name

  frontend_ip_configuration {
    name                          = "mylb-frontend"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = "10.74.1.5"
  }

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_lb_backend_address_pool" "mylb" {
  resource_group_name = azurerm_resource_group.myrg.name
  loadbalancer_id     = azurerm_lb.mylb.id
  name                = "my-backend-address-pool"
}

resource "azurerm_lb_probe" "mylb" {
  resource_group_name = azurerm_resource_group.myrg.name
  loadbalancer_id     = azurerm_lb.mylb.id
  name                = "my-hp"
  protocol            = "Tcp"
  port                = 62503
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load balancing rules for HANA 2.0

resource "azurerm_lb_rule" "lb_30313" {
  resource_group_name            = azurerm_resource_group.myrg.name
  loadbalancer_id                = azurerm_lb.mylb.id
  name                           = "hana-lb-30313"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "mylb-frontend"
  frontend_port                  = 30313
  backend_port                   = 30313
  backend_address_pool_id        = azurerm_lb_backend_address_pool.mylb.id
  probe_id                       = azurerm_lb_probe.mylb.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "lb_30314" {
  resource_group_name            = azurerm_resource_group.myrg.name
  loadbalancer_id                = azurerm_lb.mylb.id
  name                           = "hana-lb-30314"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "mylb-frontend"
  frontend_port                  = 30314
  backend_port                   = 30314
  backend_address_pool_id        = azurerm_lb_backend_address_pool.mylb.id
  probe_id                       = azurerm_lb_probe.mylb.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "lb_30340" {
  resource_group_name            = azurerm_resource_group.myrg.name
  loadbalancer_id                = azurerm_lb.mylb.id
  name                           = "hana-lb-30340"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "mylb-frontend"
  frontend_port                  = 30340
  backend_port                   = 30340
  backend_address_pool_id        = azurerm_lb_backend_address_pool.mylb.id
  probe_id                       = azurerm_lb_probe.mylb.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "lb_30341" {
  resource_group_name            = azurerm_resource_group.myrg.name
  loadbalancer_id                = azurerm_lb.mylb.id
  name                           = "hana-lb-30341"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "mylb-frontend"
  frontend_port                  = 30341
  backend_port                   = 30341
  backend_address_pool_id        = azurerm_lb_backend_address_pool.mylb.id
  probe_id                       = azurerm_lb_probe.mylb.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "lb_30342" {
  resource_group_name            = azurerm_resource_group.myrg.name
  loadbalancer_id                = azurerm_lb.mylb.id
  name                           = "hana-lb-30342"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "mylb-frontend"
  frontend_port                  = 30342
  backend_port                   = 30342
  backend_address_pool_id        = azurerm_lb_backend_address_pool.mylb.id
  probe_id                       = azurerm_lb_probe.mylb.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

# Load balancing rules for HANA 1.0

resource "azurerm_lb_rule" "lb_30315" {
  resource_group_name            = azurerm_resource_group.myrg.name
  loadbalancer_id                = azurerm_lb.mylb.id
  name                           = "hana-lb-30315"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "mylb-frontend"
  frontend_port                  = 30315
  backend_port                   = 30315
  backend_address_pool_id        = azurerm_lb_backend_address_pool.mylb.id
  probe_id                       = azurerm_lb_probe.mylb.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "lb_30317" {
  resource_group_name            = azurerm_resource_group.myrg.name
  loadbalancer_id                = azurerm_lb.mylb.id
  name                           = "hana-lb-30317"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "mylb-frontend"
  frontend_port                  = 30317
  backend_port                   = 30317
  backend_address_pool_id        = azurerm_lb_backend_address_pool.mylb.id
  probe_id                       = azurerm_lb_probe.mylb.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

# NICs & Public IP resources


resource "azurerm_network_interface" "monitoring" {
  name                      = "iscsisrv-nic"
  location                  = var.az_region
  resource_group_name       = azurerm_resource_group.myrg.name
  network_security_group_id = azurerm_network_security_group.mysecgroup.id

  ip_configuration {
    name                          = "MyNicConfiguration"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = "10.74.1.11"
    public_ip_address_id          = azurerm_public_ip.iscsisrv.id
  }

  tags = {
    workspace = terraform.workspace
  }
}


resource "azurerm_public_ip" "monitoring" {
  name                    = "monitoring-ip"
  location                = var.az_region
  resource_group_name     = azurerm_resource_group.myrg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = terraform.workspace
  }
}




resource "azurerm_network_interface" "iscsisrv" {
  name                      = "iscsisrv-nic"
  location                  = var.az_region
  resource_group_name       = azurerm_resource_group.myrg.name
  network_security_group_id = azurerm_network_security_group.mysecgroup.id

  ip_configuration {
    name                          = "MyNicConfiguration"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = "10.74.1.10"
    public_ip_address_id          = azurerm_public_ip.iscsisrv.id
  }

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_public_ip" "iscsisrv" {
  name                    = "iscsisrv-ip"
  location                = var.az_region
  resource_group_name     = azurerm_resource_group.myrg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_network_interface" "clusternodes" {
  count                     = var.ninstances
  name                      = "clusternodes-nic-${count.index}"
  location                  = var.az_region
  resource_group_name       = azurerm_resource_group.myrg.name
  network_security_group_id = azurerm_network_security_group.mysecgroup.id

  ip_configuration {
    name                          = "MyNicConfiguration-${count.index}"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.host_ips, count.index)
    public_ip_address_id          = element(azurerm_public_ip.clusternodes.*.id, count.index)
  }

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_public_ip" "clusternodes" {
  count                   = var.ninstances
  name                    = "clusternodes-ip-${count.index}"
  location                = var.az_region
  resource_group_name     = azurerm_resource_group.myrg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "clusternodes" {
  count                   = var.ninstances
  network_interface_id    = element(azurerm_network_interface.clusternodes.*.id, count.index)
  ip_configuration_name   = "MyNicConfiguration-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.mylb.id
}

# Subnet route table

resource "azurerm_route_table" "myroutes" {
  name                = "myroutes"
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name

  route {
    name           = "routes"
    address_prefix = "10.74.0.0/16"
    next_hop_type  = "vnetlocal"
  }

  tags = {
    workspace = terraform.workspace
  }
}

# Security group

resource "azurerm_network_security_group" "mysecgroup" {
  name                = "mysecgroup"
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name

  security_rule {
    name                       = "OUTALL"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "LOCAL"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.74.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HAWK"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7630"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    workspace = terraform.workspace
  }
}

