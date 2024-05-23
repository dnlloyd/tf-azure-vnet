resource "azurerm_virtual_network" "spoke_01" {
  name                = "Spoke01"
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  address_space       = [local.spoke_01_vnet_address_space]

  tags = local.tags
}

# Private
resource "azurerm_subnet" "transit_spoke_01" {
  name                 = "Spoke01"
  resource_group_name  = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  virtual_network_name = azurerm_virtual_network.spoke_01.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_route_table" "transit_spoke_01" {
  name                          = "spoke_01"
  location                      = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name           = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  route {
    name           = "local"
    address_prefix = local.transit_vnet_address_space
    next_hop_type  = "VnetLocal"
  }

  tags = local.tags
}

resource "azurerm_subnet_route_table_association" "transit_spoke_01" {
  route_table_id = azurerm_route_table.transit_spoke_01.id
  subnet_id      = azurerm_subnet.transit_spoke_01.id
}