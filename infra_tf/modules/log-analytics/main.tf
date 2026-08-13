resource "azurerm_log_analytics_workspace" "main" {
  name                = coalesce(var.name, "log-${var.solution_name}")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku_name
  retention_in_days   = var.retention_in_days
  tags                = var.tags

  identity { type = "SystemAssigned" }
}