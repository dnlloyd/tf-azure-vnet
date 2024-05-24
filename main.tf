# data "azurerm_resource_group" "this" {
#   name = var.resource_group_name
# }

resource "azurerm_virtual_network" "this" {
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  name                = "Transit"  # TODO: rename to BU-Transit
  
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

# Public
resource "azurerm_subnet" "public" {
  resource_group_name = var.resource_group_name
  
  name                 = "Public"
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.public_subnet_prefixes
}

resource "azurerm_route_table" "public" {
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  name = "public"
  tags = var.tags

  route {
    name           = "local"
    address_prefix = var.vnet_address_space
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "public" {
  route_table_id = azurerm_route_table.public.id
  subnet_id      = azurerm_subnet.public.id
}

# Private
resource "azurerm_subnet" "private" {
  resource_group_name  = var.resource_group_name
  
  name                 = "Private"
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.private_subnet_prefixes
}

resource "azurerm_route_table" "private" {
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name

  name = "private"
  tags = var.tags

  route {
    name           = "local"
    address_prefix = var.vnet_address_space
    next_hop_type  = "VnetLocal"
  }
}

resource "azurerm_subnet_route_table_association" "private" {
  route_table_id = azurerm_route_table.private.id
  subnet_id      = azurerm_subnet.private.id
}

# NAT Gateway
resource "azurerm_public_ip" "nat_gw" {
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  name                = "NAT-Gateway"
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "this" {
  location                = var.resource_group_location
  resource_group_name     = var.resource_group_name

  name                    = "NAT-Gateway"
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "transit_private" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat_gw.id
}

resource "azurerm_subnet_nat_gateway_association" "transit_private" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}
