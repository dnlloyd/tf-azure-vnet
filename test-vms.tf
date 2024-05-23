resource "azurerm_network_interface" "bu_tf_testing" {
  name                = "bu-tf-testing"
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.transit_private.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "azurerm_linux_virtual_machine" "bu_tf_testing" {
  name                = "bu-tf-testing"
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location

  size                = "Standard_F2"
  admin_username      = "adminuser"
  
  network_interface_ids = [
    azurerm_network_interface.bu_tf_testing.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azure/adminuser.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = local.tags
}

resource "azurerm_network_interface" "bu_tf_testing_2" {
  name                = "bu-tf-testing-2"
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.transit_private.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "azurerm_linux_virtual_machine" "bu_tf_testing_2" {
  name                = "bu-tf-testing-2"
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location

  size                = "Standard_F2"
  admin_username      = "adminuser"
  
  network_interface_ids = [
    azurerm_network_interface.bu_tf_testing_2.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azure/adminuser.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = local.tags
}










resource "azurerm_network_security_group" "web_vms" {
  name                = "WebVMs"
  location            = azurerm_resource_group.bu_tf_testing_transit_vnet.location
  resource_group_name = azurerm_resource_group.bu_tf_testing_transit_vnet.name

  tags = local.tags
}

resource "azurerm_network_interface_security_group_association" "web_vms" {
  network_interface_id      = azurerm_network_interface.bu_tf_testing.id
  network_security_group_id = azurerm_network_security_group.web_vms.id
}

resource "azurerm_network_interface_security_group_association" "web_vms2" {
  network_interface_id      = azurerm_network_interface.bu_tf_testing_2.id
  network_security_group_id = azurerm_network_security_group.web_vms.id
}

resource "azurerm_network_security_rule" "web_vms_inbound_allow_all" {  # TODO: Refine
  name                        = "Inbound_Allow_Any_Any"
  network_security_group_name = azurerm_network_security_group.web_vms.name
  resource_group_name         = azurerm_resource_group.bu_tf_testing_transit_vnet.name
  
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
