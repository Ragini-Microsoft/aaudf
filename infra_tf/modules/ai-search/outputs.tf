output "resource_id" { value = azurerm_search_service.main.id }
output "name" { value = azurerm_search_service.main.name }
output "endpoint" { value = "https://${azurerm_search_service.main.name}.search.windows.net" }
output "identity_principal_id" { value = azurerm_search_service.main.identity[0].principal_id }