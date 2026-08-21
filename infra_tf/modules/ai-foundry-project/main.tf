locals {
  account_name = coalesce(var.name, "aif-${var.solution_name}")
  project_name = coalesce(var.project_name, "proj-${var.solution_name}")
}

resource "azapi_resource" "account" {
  type                      = "Microsoft.CognitiveServices/accounts@2025-12-01"
  name                      = local.account_name
  parent_id                 = var.resource_group_id
  location                  = var.location
  tags                      = var.tags
  schema_validation_enabled = false

  identity { type = "SystemAssigned" }

  body = {
    kind = "AIServices"
    sku  = { name = var.sku_name }
    properties = {
      allowProjectManagement = var.allow_project_management
      customSubDomainName    = local.account_name
      networkAcls = {
        defaultAction       = var.network_acls_default_action
        virtualNetworkRules = []
        ipRules             = []
      }
      publicNetworkAccess = var.public_network_access
      disableLocalAuth    = var.disable_local_auth
    }
  }

  response_export_values = ["properties.endpoint", "properties.endpoints", "identity.principalId"]
}

resource "azapi_resource" "project" {
  type                      = "Microsoft.CognitiveServices/accounts/projects@2025-12-01"
  name                      = local.project_name
  parent_id                 = azapi_resource.account.id
  location                  = var.location
  schema_validation_enabled = false

  identity { type = "SystemAssigned" }

  body = {
    kind       = "AIServices"
    properties = {}
  }

  response_export_values = ["properties.endpoints", "identity.principalId"]
}