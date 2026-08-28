output "AZURE_STORAGE_ACCOUNT_NAME" {
  value = azurerm_storage_account.main.name
}

output "AZURE_RESOURCE_GROUP" {
  value = azurerm_resource_group.main.name
}
