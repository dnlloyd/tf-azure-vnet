output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}
