resource "azurerm_network_security_group" "default" {
  name                = "Default"
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "default_public" {
  network_security_group_id = azurerm_network_security_group.default.id
  subnet_id                 = azurerm_subnet.public.id
}

# resource "azurerm_network_security_rule" "deny_all" {
#   name                        = "deny_all"
#   resource_group_name         = azurerm_resource_group.bu_tf_testing_transit_vnet.name
#   network_security_group_name = azurerm_network_security_group.default.name

#   priority                   = 100
#   direction                  = "Inbound"
#   access                     = "Deny"
#   protocol                   = "Tcp"
#   source_port_range          = "*"
#   destination_port_range     = "*"
#   source_address_prefix      = "*"
#   destination_address_prefix = "*"
# }
