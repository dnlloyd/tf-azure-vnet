resource "azurerm_subnet" "bastion" {
  count               = var.transit_bastion_subnet_prefixes == null ? 0 : 1
  resource_group_name = var.resource_group_name

  name                 = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.transit_bastion_subnet_prefixes
}

resource "azurerm_public_ip" "bastion" {
  count               = var.transit_bastion_subnet_prefixes == null ? 0 : 1
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  name              = "Bastion"
  allocation_method = "Static"
  sku               = "Standard"
  tags              = var.tags
}

resource "azurerm_bastion_host" "this" {
  count               = var.transit_bastion_subnet_prefixes == null ? 0 : 1
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  name = "BastionHost"
  tags = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}
