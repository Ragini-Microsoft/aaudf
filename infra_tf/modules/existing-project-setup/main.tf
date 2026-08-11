data "azapi_resource" "account" {
  type        = "Microsoft.CognitiveServices/accounts@2025-12-01"
  resource_id = var.account_id
}

data "azapi_resource" "project" {
  type        = "Microsoft.CognitiveServices/accounts/projects@2025-12-01"
  resource_id = var.project_id
}