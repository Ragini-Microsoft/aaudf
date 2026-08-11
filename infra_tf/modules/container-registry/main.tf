resource "azurerm_container_registry" "main" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tags                          = var.tags
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  data_endpoint_enabled         = false
  network_rule_bypass_option    = "AzureServices"
  export_policy_enabled         = true
  zone_redundancy_enabled       = false

  identity { type = "SystemAssigned" }
}