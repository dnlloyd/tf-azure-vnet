locals {
  transit_vnet_address_space = "10.0.0.0/16"
  spoke_01_vnet_address_space = "10.1.0.0/16"
  spoke_02_vnet_address_space = "10.2.0.0/16"

  tags = {
    use = "BU Terraform Testing"
    createdBy = "Terraform"
    owner = "Daniel Lloyd"
  }
}

resource "azurerm_resource_group" "bu_tf_testing_transit_vnet" {
  name     = "bu-tf-testing-transit-vnet"
  location = "Central US"

  tags = local.tags
}
