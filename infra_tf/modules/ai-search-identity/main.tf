data "azapi_resource" "search" {
  type        = "Microsoft.Search/searchServices@2025-05-01"
  resource_id = var.search_service_id
}