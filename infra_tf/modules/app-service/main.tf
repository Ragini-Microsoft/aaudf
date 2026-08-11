data "azurerm_resource_group" "main" { name = var.resource_group_name }

resource "azapi_resource" "site" {
  type                      = "Microsoft.Web/sites@2025-05-01"
  name                      = var.name
  parent_id                 = data.azurerm_resource_group.main.id
  schema_validation_enabled = false
  location                  = var.location
  tags                      = var.tags
  identity {
    type = "SystemAssigned"
  }
  body = {
    kind = "app,linux"
    properties = {
      serverFarmId              = var.service_plan_id
      publicNetworkAccess       = var.public_network_access
      endToEndEncryptionEnabled = true
      siteConfig = {
        alwaysOn                   = var.always_on
        ftpsState                  = "Disabled"
        linuxFxVersion             = var.linux_fx_version
        minTlsVersion              = "1.2"
        healthCheckPath            = var.health_check_path != "" ? var.health_check_path : null
        webSocketsEnabled          = var.web_sockets_enabled
        appCommandLine             = var.app_command_line
        acrUseManagedIdentityCreds = var.acr_use_managed_identity_credentials
      }
    }
  }
}

resource "azapi_resource" "ftp_policy" {
  type                      = "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2025-05-01"
  name                      = "ftp"
  parent_id                 = azapi_resource.site.id
  schema_validation_enabled = false
  body                      = { properties = { allow = false } }
}

resource "azapi_resource" "scm_policy" {
  type                      = "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2025-05-01"
  name                      = "scm"
  parent_id                 = azapi_resource.site.id
  schema_validation_enabled = false
  body                      = { properties = { allow = false } }
}

resource "azapi_resource" "app_settings" {
  type                      = "Microsoft.Web/sites/config@2025-05-01"
  name                      = "appsettings"
  parent_id                 = azapi_resource.site.id
  schema_validation_enabled = false
  body                      = { properties = var.app_settings }
}

resource "azapi_resource" "logs" {
  type                      = "Microsoft.Web/sites/config@2025-05-01"
  name                      = "logs"
  parent_id                 = azapi_resource.site.id
  schema_validation_enabled = false
  body = {
    properties = {
      applicationLogs       = { fileSystem = { level = "Verbose" } }
      detailedErrorMessages = { enabled = true }
      failedRequestsTracing = { enabled = true }
      httpLogs              = { fileSystem = { enabled = true, retentionInDays = 1, retentionInMb = 35 } }
    }
  }
  depends_on = [azapi_resource.app_settings]
}