locals {
  docker_image   = trimprefix(var.linux_fx_version, "DOCKER|")
  image_segments = split("/", local.docker_image)
  registry_host  = local.image_segments[0]
  image_name     = join("/", slice(local.image_segments, 1, length(local.image_segments)))
}

resource "azurerm_linux_web_app" "main" {
  name                                           = coalesce(var.name, var.solution_name)
  resource_group_name                            = var.resource_group_name
  location                                       = var.location
  service_plan_id                                = var.server_farm_resource_id
  public_network_access_enabled                  = var.public_network_access == "Enabled"
  https_only                                     = true
  app_settings                                   = var.app_settings
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  tags                                           = var.tags

  identity { type = "SystemAssigned" }

  site_config {
    always_on                               = var.always_on
    ftps_state                              = "Disabled"
    minimum_tls_version                     = "1.2"
    health_check_path                       = var.health_check_path == "" ? null : var.health_check_path
    websockets_enabled                      = var.web_sockets_enabled
    app_command_line                        = var.app_command_line
    container_registry_use_managed_identity = var.acr_use_managed_identity_creds

    application_stack {
      docker_image_name   = local.image_name
      docker_registry_url = "https://${local.registry_host}"
    }
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    application_logs { file_system_level = "Verbose" }
    http_logs {
      file_system {
        retention_in_days = 1
        retention_in_mb   = 35
      }
    }
  }
}

resource "azapi_update_resource" "end_to_end_encryption" {
  type        = "Microsoft.Web/sites@2025-05-01"
  resource_id = azurerm_linux_web_app.main.id

  body = {
    properties = {
      endToEndEncryptionEnabled = true
    }
  }
}