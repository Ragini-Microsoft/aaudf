resource "azapi_resource" "main" {
  type                      = "Microsoft.CognitiveServices/accounts/deployments@2025-12-01"
  name                      = var.deployment_name
  parent_id                 = var.account_id
  schema_validation_enabled = false
  body = {
    sku = { name = var.sku_name, capacity = var.sku_capacity }
    properties = {
      model = merge(
        { format = var.model_format, name = var.model_name },
        var.model_version != "" ? { version = var.model_version } : {}
      )
      raiPolicyName = var.rai_policy_name
    }
  }
}