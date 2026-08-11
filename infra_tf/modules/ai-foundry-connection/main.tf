locals {
  base_properties = {
    category                    = var.category
    target                      = var.target
    authType                    = var.auth_type
    isSharedToAll               = var.is_shared_to_all
    metadata                    = var.metadata
    useWorkspaceManagedIdentity = var.use_workspace_managed_identity
  }
  properties = merge(
    local.base_properties,
    var.is_default ? { isDefault = true } : {},
    var.credentials_key != "" ? { credentials = { key = var.credentials_key } } : {}
  )
}

resource "azapi_resource" "main" {
  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-12-01"
  name                      = var.connection_name
  parent_id                 = var.parent_id
  schema_validation_enabled = false
  body                      = { properties = local.properties }

  lifecycle {
    ignore_changes = [body]
  }
}