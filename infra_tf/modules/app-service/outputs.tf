output "resource_id" { value = azapi_resource.site.id }
output "name" { value = azapi_resource.site.name }
output "default_hostname" { value = azapi_resource.site.output.properties.defaultHostName }
output "app_url" { value = "https://${azapi_resource.site.output.properties.defaultHostName}" }
output "identity_principal_id" { value = azapi_resource.site.output.identity.principalId }