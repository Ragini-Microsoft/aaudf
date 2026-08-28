resource "random_string" "suffix" {
  length  = 5
  lower   = true
  numeric = true
  special = false
  upper   = false
}

locals {
  solution_suffix = "${var.solution_name}${random_string.suffix.result}"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.solution_suffix}"
  location = var.location
}

resource "azurerm_storage_account" "main" {
  name                     = "st${local.solution_suffix}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "AZURE_STORAGE_ACCOUNT_NAME" {
  value = azurerm_storage_account.main.name
}

output "AZURE_RESOURCE_GROUP" {
  value = azurerm_resource_group.main.name
}
