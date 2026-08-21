resource "azapi_resource" "main" {
  type                      = "Microsoft.CognitiveServices/accounts/deployments@2025-12-01"
  name                      = var.deployment_name
  parent_id                 = "${var.resource_group_id}/providers/Microsoft.CognitiveServices/accounts/${var.ai_services_account_name}"
  schema_validation_enabled = false

  body = {
    properties = {
      model = {
        format  = var.model_format
        name    = var.model_name
        version = var.model_version != "" ? var.model_version : null
      }
      raiPolicyName = var.rai_policy_name
    }
    sku = {
      name     = var.sku_name
      capacity = var.sku_capacity
    }
  }
}