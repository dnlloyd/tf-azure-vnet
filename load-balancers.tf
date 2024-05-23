resource "azurerm_public_ip" "transit_lb" {
  name                = "PublicIPForTransitLB"
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

resource "azurerm_lb" "transit" {
  name                = "Transit"
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  sku                = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.transit_lb.id
  }

  tags = local.tags
}

resource "azurerm_lb_backend_address_pool" "test" {
  loadbalancer_id = azurerm_lb.transit.id
  name            = "BackEndTest"
}

resource "azurerm_lb_backend_address_pool_address" "test" {
  name                    = "Test"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
  virtual_network_id      = azurerm_virtual_network.transit.id
  ip_address              = azurerm_network_interface.bu_tf_testing.private_ip_address
}

resource "azurerm_lb_backend_address_pool_address" "test_2" {
  name                    = "Test2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
  virtual_network_id      = azurerm_virtual_network.transit.id
  ip_address              = azurerm_network_interface.bu_tf_testing_2.private_ip_address
}

resource "azurerm_lb_rule" "test" {
  loadbalancer_id                = azurerm_lb.transit.id
  name                           = "WebRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.test.id]

  probe_id = azurerm_lb_probe.test.id
  enable_tcp_reset = true
  disable_outbound_snat = true
}

resource "azurerm_lb_probe" "test" {
  loadbalancer_id = azurerm_lb.transit.id
  name            = "http-test"
  port            = 80
}
