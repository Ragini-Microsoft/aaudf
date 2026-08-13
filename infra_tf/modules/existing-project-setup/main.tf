data "azapi_resource" "account" {
  type        = "Microsoft.CognitiveServices/accounts@2025-12-01"
  resource_id = "${var.resource_group_id}/providers/Microsoft.CognitiveServices/accounts/${var.name}"

  response_export_values = ["properties.endpoint", "properties.endpoints", "identity.principalId"]
}

data "azapi_resource" "project" {
  type        = "Microsoft.CognitiveServices/accounts/projects@2025-12-01"
  resource_id = "${data.azapi_resource.account.id}/projects/${var.project_name}"

  response_export_values = ["properties.endpoints", "identity.principalId"]
}