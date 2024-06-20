variable "resource_group_name" {}

variable "resource_group_location" {}

variable "name" {}

variable "vnet_address_space" {}

variable "public_subnet_prefixes" {
  description = "The address prefixes for the public subnet. If null, no public subnet will be deployed."
  default     = null
}

variable "private_subnet_prefixes" {}

variable "bastion_subnet_prefixes" {
  description = "The address prefixes for the Azure Bastion subnet. If null, no Azure Bastion will be deployed."
  default     = null
}

variable "tags" {}
