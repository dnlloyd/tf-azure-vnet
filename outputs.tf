output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "public_subnet_id" {
  value = try(azurerm_subnet.public[0].id, null)
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}
