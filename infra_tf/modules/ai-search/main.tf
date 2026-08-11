resource "azurerm_search_service" "main" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tags                          = var.tags
  sku                           = var.sku_name
  replica_count                 = var.replica_count
  partition_count               = var.partition_count
  hosting_mode                  = lower(var.hosting_mode)
  semantic_search_sku           = var.semantic_search
  local_authentication_enabled  = !var.disable_local_auth
  public_network_access_enabled = var.public_network_access == "Enabled"

  identity {
    type = "SystemAssigned"
  }
}