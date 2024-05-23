resource "azurerm_network_security_group" "transit_public" {
  name                = "TransitPublic"
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "transit_public" {
  network_security_group_id = azurerm_network_security_group.transit_public.id
  subnet_id                 = azurerm_subnet.transit_public.id
}

# resource "azurerm_network_security_rule" "deny_all" {
#   name                        = "deny_all"
#   resource_group_name         = azurerm_resource_group.bu_tf_testing_transit_vnet.name
#   network_security_group_name = azurerm_network_security_group.transit_public.name

#   priority                   = 100
#   direction                  = "Inbound"
#   access                     = "Deny"
#   protocol                   = "Tcp"
#   source_port_range          = "*"
#   destination_port_range     = "*"
#   source_address_prefix      = "*"
#   destination_address_prefix = "*"
# }

resource "azurerm_network_security_group" "transit_private" {
  name                = "Private"
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "transit_private" {
  network_security_group_id = azurerm_network_security_group.transit_private.id
  subnet_id                 = azurerm_subnet.transit_private.id
}







# Inbound rules
resource "azurerm_network_security_rule" "transit_private_inbound_allow_all" { # TODO: Refine
  name                        = "Inbound_Allow_Any_Any"
  network_security_group_name = azurerm_network_security_group.transit_private.name
  resource_group_name         = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = azurerm_subnet.transit_private.address_prefixes[0]
}

resource "azurerm_network_security_rule" "transit_private_inbound_allow_all_from_subnet" {
  name                        = "Inbound_Allow_Subnet_Any"
  network_security_group_name = azurerm_network_security_group.transit_private.name
  resource_group_name         = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.transit_private.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.transit_private.address_prefixes[0]
}

resource "azurerm_network_security_rule" "transit_private_inbound_allow_ssh_from_bastion" {
  name                        = "Inbound-Allow-Bastion-SSH"
  network_security_group_name = azurerm_network_security_group.transit_private.name
  resource_group_name         = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  
  priority                    = 510
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = azurerm_subnet.bastion.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.transit_private.address_prefixes[0]
}

resource "azurerm_network_security_rule" "transit_private_inbound_allow_http_from_lb" {
  name                        = "Inbound-Allow-LB-http"
  network_security_group_name = azurerm_network_security_group.transit_private.name
  resource_group_name         = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  
  priority                    = 511
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = azurerm_subnet.transit_private.address_prefixes[0]
}

# resource "azurerm_network_security_rule" "transit_private_inbound_deny_all" {
#   name                        = "Inbound_Deny_Any_Any"
#   network_security_group_name = azurerm_network_security_group.transit_private.name
#   resource_group_name         = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  
#   priority                    = 1000
#   direction                   = "Inbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = azurerm_subnet.transit_private.address_prefixes[0]
# }









# Outbound rules
resource "azurerm_network_security_rule" "transit_private_outbound_allow_all_to_subnet" {
  name                        = "Outbound_Allow_Subnet_Any"
  network_security_group_name = azurerm_network_security_group.transit_private.name
  resource_group_name         = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  
  priority                    = 500
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.transit_private.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.transit_private.address_prefixes[0]
}