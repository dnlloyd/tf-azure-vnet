resource "azurerm_virtual_network" "transit" {
  name                = "Transit"  # TODO: rename to BU-Transit
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  address_space       = [local.transit_vnet_address_space]

  tags = local.tags
}

# Public
resource "azurerm_subnet" "transit_public" {
  name                 = "Public"
  resource_group_name  = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_route_table" "transit_public" {
  name                          = "public"
  location                      = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name           = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  route {
    name           = "local"
    address_prefix = local.transit_vnet_address_space
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = local.tags
}

resource "azurerm_subnet_route_table_association" "transit_public" {
  route_table_id = azurerm_route_table.transit_public.id
  subnet_id      = azurerm_subnet.transit_public.id
}

# Private
resource "azurerm_subnet" "transit_private" {
  name                 = "Private"
  resource_group_name  = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_route_table" "transit_private" {
  name                          = "private"
  location                      = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name           = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  route {
    name           = "local"
    address_prefix = local.transit_vnet_address_space
    next_hop_type  = "VnetLocal"
  }

  tags = local.tags
}

resource "azurerm_subnet_route_table_association" "transit_private" {
  route_table_id = azurerm_route_table.transit_private.id
  subnet_id      = azurerm_subnet.transit_private.id
}

# NAT Gateway
resource "azurerm_public_ip" "transit_nat" {
  name                = "TransitNAT"
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "transit" {
  name                    = "Transit"
  location                = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name     = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "transit_private" {
  nat_gateway_id       = azurerm_nat_gateway.transit.id
  public_ip_address_id = azurerm_public_ip.transit_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "transit_private" {
  subnet_id      = azurerm_subnet.transit_private.id
  nat_gateway_id = azurerm_nat_gateway.transit.id
}
