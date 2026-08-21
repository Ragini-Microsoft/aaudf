resource "azurerm_cosmosdb_account" "main" {
  name                             = coalesce(var.name, "cosmos-${var.solution_name}")
  location                         = var.location
  resource_group_name              = var.resource_group_name
  offer_type                       = "Standard"
  kind                             = "GlobalDocumentDB"
  local_authentication_enabled     = false
  automatic_failover_enabled       = false
  multiple_write_locations_enabled = false
  tags                             = var.tags

  consistency_policy { consistency_level = "Session" }
  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = false
  }
  capabilities { name = "EnableServerless" }
  identity { type = "SystemAssigned" }
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
}

resource "azurerm_cosmosdb_sql_container" "main" {
  for_each              = { for container in var.containers : container.name => container }
  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  account_name          = azurerm_cosmosdb_account.main.name
  database_name         = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths   = [each.value.partition_key_path]
  partition_key_version = 1
}