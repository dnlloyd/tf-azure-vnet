resource "azurerm_virtual_network" "this" {
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  name          = var.name
  address_space = [var.vnet_address_space]
  tags          = var.tags
}

# Public subnets
resource "azurerm_subnet" "public" {
  count               = var.public_subnet_prefixes == null ? 0 : 1
  resource_group_name = var.resource_group_name

  name                 = "Public"
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.public_subnet_prefixes
}

# resource "azurerm_route_table" "public" {
#   count               = var.public_subnet_prefixes == null ? 0 : 1
#   location            = var.resource_group_location
#   resource_group_name = var.resource_group_name

#   name = "public"
#   tags = var.tags

#   route {
#     name           = "local"
#     address_prefix = var.vnet_address_space
#     next_hop_type  = "VnetLocal"
#   }

#   route {
#     name           = "internet"
#     address_prefix = "0.0.0.0/0"
#     next_hop_type  = "Internet"
#   }
# }

# resource "azurerm_subnet_route_table_association" "public" {
#   count = var.public_subnet_prefixes == null ? 0 : 1

#   route_table_id = azurerm_route_table.public[0].id
#   subnet_id      = azurerm_subnet.public[0].id
# }

# Private subnets
# TODO: public IPs attached to network interfaces configured in private subnets are still pubic accessible
# TODO: configure routing table to route traffic to NAT Gateway
resource "azurerm_subnet" "private" {
  resource_group_name = var.resource_group_name

  name                 = "Private"
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.private_subnet_prefixes

  default_outbound_access_enabled = false
}

# resource "azurerm_route_table" "private_subnet" {
#   count               = var.private_subnet_prefixes == null ? 0 : 1
#   location            = var.resource_group_location
#   resource_group_name = var.resource_group_name

#   name = "private-subnet-rt"
#   tags = var.tags

#   route {
#     name           = "internet"
#     address_prefix = "0.0.0.0/0"
#     next_hop_type  = "Internet"
#   }
# }

# resource "azurerm_route_table" "private" {
#   location            = var.resource_group_location
#   resource_group_name = var.resource_group_name

#   name = "private"
#   tags = var.tags

#   route {
#     name           = "local"
#     address_prefix = var.vnet_address_space
#     next_hop_type  = "VnetLocal"
#   }
# }

# resource "azurerm_subnet_route_table_association" "private_subnet" {
#   route_table_id = azurerm_route_table.private_subnet.id
#   subnet_id      = azurerm_subnet.private.id
# }

# NAT Gateway  # TODO: Validate this
resource "azurerm_public_ip" "nat_gw" {
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  name              = "NAT-Gateway"
  allocation_method = "Static"
  sku               = "Standard"
  zones             = ["1"]
}

resource "azurerm_nat_gateway" "this" {
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  name                    = "NAT-Gateway"  # TODO: rename
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gw" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat_gw.id
}

resource "azurerm_subnet_nat_gateway_association" "private_nat_gw" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}
