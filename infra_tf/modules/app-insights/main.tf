resource "azurerm_application_insights" "main" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tags                       = var.tags
  workspace_id               = var.workspace_resource_id
  application_type           = var.application_type
  retention_in_days          = var.retention_in_days
  disable_ip_masking         = var.disable_ip_masking
  internet_ingestion_enabled = true
  internet_query_enabled     = true
}