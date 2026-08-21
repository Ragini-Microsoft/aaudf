locals {
  account_tier             = split("_", var.sku_name)[0]
  account_replication_type = split("_", var.sku_name)[1]
}

resource "azurerm_storage_account" "main" {
  name                              = coalesce(var.name, substr("st${lower(replace(var.solution_name, "-", ""))}", 0, 24))
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = local.account_tier
  account_replication_type          = local.account_replication_type
  account_kind                      = var.kind
  access_tier                       = var.access_tier
  allow_nested_items_to_be_public   = var.allow_blob_public_access
  shared_access_key_enabled         = var.allow_shared_key_access
  is_hns_enabled                    = var.enable_hierarchical_namespace
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = true
  tags                              = var.tags

  identity { type = "SystemAssigned" }
}

resource "azurerm_storage_container" "main" {
  for_each              = { for container in var.containers : container.name => container }
  name                  = each.value.name
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = lower(each.value.public_access) == "none" ? "private" : lower(each.value.public_access)
}