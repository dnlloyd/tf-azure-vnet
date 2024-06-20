provider "azurerm" {
  features {}
}

locals {
  vnet_address_space      = "10.1.0.0/16"
  private_subnet_prefixes = ["10.1.0.0/22"]
  public_subnet_prefixes  = ["10.1.4.0/22"]
  bastion_subnet_prefixes = ["10.1.255.0/24"]

  tags = {
    use       = "BU Terraform Testing"
    createdBy = "Terraform"
    owner     = "Daniel Lloyd"
  }
}

resource "azurerm_resource_group" "tf_testing" {
  name     = "bu-transit-network"
  location = "Central US"

  tags = local.tags
}


module "test_vnet" {
  source = "../"

  resource_group_name     = azurerm_resource_group.tf_testing.name
  resource_group_location = azurerm_resource_group.tf_testing.location

  name                            = "TF-Testing-VNet"
  vnet_address_space              = local.vnet_address_space
  public_subnet_prefixes          = local.public_subnet_prefixes
  private_subnet_prefixes         = local.private_subnet_prefixes
  bastion_subnet_prefixes         = local.bastion_subnet_prefixes
  tags                            = local.tags
}
