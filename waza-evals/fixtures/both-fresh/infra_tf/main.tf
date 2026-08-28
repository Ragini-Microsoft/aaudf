resource "random_string" "suffix" {
  length  = 5
  lower   = true
  numeric = true
  special = false
  upper   = false
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.solution_name}${random_string.suffix.result}"
  location = var.location
}

output "AZURE_RESOURCE_GROUP" {
  value = azurerm_resource_group.main.name
}
