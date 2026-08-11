resource "azurerm_service_plan" "main" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  tags                   = var.tags
  os_type                = "Linux"
  sku_name               = var.sku_name
  worker_count           = var.worker_count
  zone_balancing_enabled = var.zone_balancing_enabled
}