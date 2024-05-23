resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = ["10.0.199.0/24"]
}

resource "azurerm_public_ip" "bastion" {
  name                = "BU-TFTest-Bastion"
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

resource "azurerm_bastion_host" "bu_tf_testing" {
  name                = "BU-TFTest"
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = local.tags
}
