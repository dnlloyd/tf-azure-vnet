locals {
  vnet_address_space = "10.0.0.0/16"

  tags = {
    createdBy = "Terraform"
    owner = "Daniel Lloyd"
  }
}

resource "azurerm_resource_group" "bu_tf_testing_transit_vnet" {
  name     = "bank-united-tf-testing-transit-vnet"
  location = "Central US"

  tags = {
    createdFrom = "Terraform"
    owner = "Daniel Lloyd"
  }
}

resource "azurerm_virtual_network" "bu_tf_testing" {
  name                = "Transit"
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  address_space       = [local.vnet_address_space]

  tags = local.tags
}

resource "azurerm_subnet" "public" {
  name                 = "public"
  resource_group_name  = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  virtual_network_name = azurerm_virtual_network.bu_tf_testing.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_route_table" "public" {
  name                          = "public"
  location                      = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name           = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  route {
    name           = "local"
    address_prefix = local.vnet_address_space
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = local.tags
}

resource "azurerm_subnet_route_table_association" "public" {
  route_table_id = azurerm_route_table.public.id
  subnet_id      = azurerm_subnet.public.id
}

resource "azurerm_subnet" "private" {
  name                 = "private"
  resource_group_name  = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  virtual_network_name = azurerm_virtual_network.bu_tf_testing.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_route_table" "private" {
  name                          = "private"
  location                      = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name           = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  route {
    name           = "local"
    address_prefix = local.vnet_address_space
    next_hop_type  = "VnetLocal"
  }

  tags = local.tags
}

resource "azurerm_subnet_route_table_association" "private" {
  route_table_id = azurerm_route_table.private.id
  subnet_id      = azurerm_subnet.private.id
}
