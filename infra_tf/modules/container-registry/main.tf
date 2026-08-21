resource "azurerm_container_registry" "main" {
  name                          = coalesce(var.name, replace("cr${var.solution_name}", "-", ""))
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_user_enabled
  public_network_access_enabled = var.public_network_access == "Enabled"
  data_endpoint_enabled         = false
  network_rule_bypass_option    = "AzureServices"
  export_policy_enabled         = var.export_policy_enabled
  zone_redundancy_enabled       = false
  tags                          = var.tags

  identity { type = "SystemAssigned" }
}