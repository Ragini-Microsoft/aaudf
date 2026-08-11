resource "random_string" "suffix" {
  count = var.solution_unique_text == "" ? 1 : 0

  length  = 5
  lower   = true
  numeric = true
  special = false
  upper   = false
}

locals {
  solution_unique_text = var.solution_unique_text != "" ? var.solution_unique_text : random_string.suffix[0].result
  solution_suffix = lower(replace(replace(replace(replace(replace(replace(
  "${var.solution_name}${local.solution_unique_text}", "-", ""), "_", ""), ".", ""), "/", ""), " ", ""), "*", ""))
  create_fabric_workspace       = var.fabric_workspace_id == ""
  use_existing_fabric_capacity  = var.azure_fabric_capacity_name != ""
  should_create_fabric_capacity = local.create_fabric_workspace && !local.use_existing_fabric_capacity
  fabric_capacity_name          = local.use_existing_fabric_capacity ? var.azure_fabric_capacity_name : "fc${local.solution_suffix}"
  fabric_admin_members          = distinct(concat([data.azurerm_client_config.current.object_id], var.fabric_admin_members))
  use_existing_log_analytics    = var.existing_log_analytics_workspace_id != ""
  use_existing_ai_project       = var.existing_foundry_project_resource_id != ""
  existing_foundry_parts        = split("/", var.existing_foundry_project_resource_id)
  ai_foundry_subscription_id    = local.use_existing_ai_project ? local.existing_foundry_parts[2] : var.subscription_id
  ai_foundry_resource_group     = local.use_existing_ai_project ? local.existing_foundry_parts[4] : azurerm_resource_group.main.name
  ai_foundry_name               = local.use_existing_ai_project ? local.existing_foundry_parts[8] : module.ai_foundry_project[0].name
  ai_project_name               = local.use_existing_ai_project ? local.existing_foundry_parts[10] : module.ai_foundry_project[0].project_name
  ai_foundry_resource_id        = local.use_existing_ai_project ? module.existing_project_setup[0].resource_id : module.ai_foundry_project[0].resource_id
  ai_foundry_endpoint           = local.use_existing_ai_project ? module.existing_project_setup[0].endpoint : module.ai_foundry_project[0].endpoint
  ai_project_endpoint           = local.use_existing_ai_project ? module.existing_project_setup[0].project_endpoint : module.ai_foundry_project[0].project_endpoint
  ai_project_principal_id       = local.use_existing_ai_project ? module.existing_project_setup[0].project_identity_principal_id : module.ai_foundry_project[0].project_identity_principal_id
  container_registry_name       = var.container_registry_name != "" ? var.container_registry_name : substr("cr${local.solution_suffix}", 0, 50)
  use_chat_history_setting      = var.use_chat_history_enabled ? "True" : "False"
  use_user_access_token_setting = var.use_user_access_token ? "True" : "False"
  placeholder_container_image   = "DOCKER|mcr.microsoft.com/azuredocs/aci-helloworld:latest"
  backend_name                  = var.backend_runtime_stack == "python" ? "api-${local.solution_suffix}" : "api-cs-${local.solution_suffix}"
  resource_tags = merge(var.tags, {
    TemplateName   = "Unified Data Analysis Agents"
    CreatedBy      = data.azurerm_client_config.current.object_id
    DeploymentName = var.solution_name
    Type           = "Non-WAF"
  })
  backend_common_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY         = module.app_insights.instrumentation_key
    REACT_APP_LAYOUT_CONFIG                = jsonencode({ appConfig = { CHAT_CHATHISTORY = { CHAT = 70, CHATHISTORY = 30 } } })
    AZURE_ENV_GPT_MODEL_NAME               = var.gpt_model_name
    AZURE_ENV_EMBEDDING_DEPLOYMENT_NAME    = var.embedding_model
    AZURE_OPENAI_ENDPOINT                  = local.ai_foundry_endpoint
    AZURE_ENV_OPENAI_API_VERSION           = var.azure_openai_api_version
    AZURE_OPENAI_RESOURCE                  = local.ai_foundry_name
    AZURE_AI_AGENT_ENDPOINT                = local.ai_project_endpoint
    AZURE_AI_AGENT_API_VERSION             = var.azure_ai_agent_api_version
    AZURE_AI_AGENT_MODEL_DEPLOYMENT_NAME   = var.gpt_model_name
    USE_CHAT_HISTORY_ENABLED               = local.use_chat_history_setting
    AZURE_COSMOSDB_ACCOUNT                 = module.cosmos_db.name
    AZURE_COSMOSDB_CONVERSATIONS_CONTAINER = module.cosmos_db.container_name
    AZURE_COSMOSDB_DATABASE                = module.cosmos_db.database_name
    AZURE_COSMOSDB_ENABLE_FEEDBACK         = "True"
    API_UID                                = ""
    AZURE_AI_SEARCH_ENDPOINT               = module.ai_search.endpoint
    AZURE_AI_SEARCH_INDEX                  = "knowledge_index"
    AZURE_AI_SEARCH_CONNECTION_NAME        = module.foundry_search_connection.connection_name
    USE_AI_PROJECT_CLIENT                  = "True"
    DISPLAY_CHART_DEFAULT                  = "False"
    APPLICATIONINSIGHTS_CONNECTION_STRING  = module.app_insights.connection_string
    DUMMY_TEST                             = "True"
    SOLUTION_NAME                          = local.solution_suffix
    USE_USER_ACCESS_TOKEN                  = local.use_user_access_token_setting
    APP_ENV                                = "Prod"
    AGENT_NAME_CHAT                        = ""
    AGENT_NAME_TITLE                       = ""
    FABRIC_SQL_DATABASE                    = ""
    FABRIC_SQL_SERVER                      = ""
    FABRIC_SQL_CONNECTION_STRING           = ""
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.resource_tags
}

module "fabric_capacity" {
  source = "./modules/fabric-capacity"
  count  = local.should_create_fabric_capacity ? 1 : 0

  name                = local.fabric_capacity_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku_name            = var.fabric_capacity_sku
  admin_members       = local.fabric_admin_members
  tags                = local.resource_tags
}

module "log_analytics" {
  source = "./modules/log-analytics"
  count  = local.use_existing_log_analytics ? 0 : 1

  name                = "log-${local.solution_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_ai_service_location
}

module "app_insights" {
  source = "./modules/app-insights"

  name                  = "appi-${local.solution_suffix}"
  resource_group_name   = azurerm_resource_group.main.name
  location              = var.azure_ai_service_location
  workspace_resource_id = local.use_existing_log_analytics ? var.existing_log_analytics_workspace_id : module.log_analytics[0].resource_id
}

module "existing_project_setup" {
  source = "./modules/existing-project-setup"
  count  = local.use_existing_ai_project ? 1 : 0

  account_id   = join("/", slice(local.existing_foundry_parts, 0, 9))
  account_name = local.ai_foundry_name
  project_id   = var.existing_foundry_project_resource_id
  project_name = local.ai_project_name
}

module "ai_foundry_project" {
  source = "./modules/ai-foundry-project"
  count  = local.use_existing_ai_project ? 0 : 1

  account_name      = "aif-${local.solution_suffix}"
  project_name      = "proj-${local.solution_suffix}"
  resource_group_id = azurerm_resource_group.main.id
  location          = var.azure_ai_service_location
}

module "ai_search" {
  source = "./modules/ai-search"

  name                = "srch-${local.solution_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
}

module "storage_account" {
  source = "./modules/storage-account"

  name                = substr("st${replace(local.solution_suffix, "-", "")}", 0, 24)
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_ai_service_location
  containers          = [{ name = "default", public_access = "None" }]
}

module "foundry_search_connection" {
  source = "./modules/ai-foundry-connection"

  account_name    = local.ai_foundry_name
  project_name    = local.ai_project_name
  parent_id       = "/subscriptions/${local.ai_foundry_subscription_id}/resourceGroups/${local.ai_foundry_resource_group}/providers/Microsoft.CognitiveServices/accounts/${local.ai_foundry_name}/projects/${local.ai_project_name}"
  connection_name = lower("CognitiveSearch-connection-${local.solution_suffix}")
  category        = "CognitiveSearch"
  target          = module.ai_search.endpoint
  auth_type       = "AAD"
  metadata        = { ApiType = "Azure", ResourceId = module.ai_search.resource_id }
}

module "foundry_storage_connection" {
  source = "./modules/ai-foundry-connection"

  account_name    = local.ai_foundry_name
  project_name    = local.ai_project_name
  parent_id       = "/subscriptions/${local.ai_foundry_subscription_id}/resourceGroups/${local.ai_foundry_resource_group}/providers/Microsoft.CognitiveServices/accounts/${local.ai_foundry_name}/projects/${local.ai_project_name}"
  connection_name = lower("AzureBlob-connection-${local.solution_suffix}")
  category        = "AzureBlob"
  target          = module.storage_account.blob_endpoint
  auth_type       = "AAD"
  metadata        = { ResourceId = module.storage_account.resource_id, AccountName = module.storage_account.name, ContainerName = "default" }
}

module "foundry_appi_connection" {
  source = "./modules/ai-foundry-connection"
  count  = local.use_existing_ai_project ? 0 : 1

  account_name    = local.ai_foundry_name
  project_name    = local.ai_project_name
  parent_id       = "/subscriptions/${local.ai_foundry_subscription_id}/resourceGroups/${local.ai_foundry_resource_group}/providers/Microsoft.CognitiveServices/accounts/${local.ai_foundry_name}/projects/${local.ai_project_name}"
  connection_name = lower("AppInsights-connection-${local.solution_suffix}")
  category        = "AppInsights"
  target          = module.app_insights.resource_id
  auth_type       = "ApiKey"
  is_default      = true
  credentials_key = module.app_insights.instrumentation_key
  metadata        = { ApiType = "Azure", ResourceId = module.app_insights.resource_id }
}

module "model_deployments" {
  source = "./modules/ai-foundry-model-deployment"
  for_each = {
    gpt = {
      name     = var.gpt_model_name, model = var.gpt_model_name, version = var.gpt_model_version,
      sku_name = var.deployment_type, capacity = var.gpt_deployment_capacity
    }
    embedding = {
      name     = var.embedding_model, model = var.embedding_model, version = "1",
      sku_name = "GlobalStandard", capacity = var.embedding_deployment_capacity
    }
  }

  account_id      = "/subscriptions/${local.ai_foundry_subscription_id}/resourceGroups/${local.ai_foundry_resource_group}/providers/Microsoft.CognitiveServices/accounts/${local.ai_foundry_name}"
  account_name    = local.ai_foundry_name
  deployment_name = each.value.name
  model_name      = each.value.model
  model_version   = each.value.version
  sku_name        = each.value.sku_name
  sku_capacity    = each.value.capacity
}

module "cosmos_db" {
  source = "./modules/cosmos-db-nosql"

  name                = "cosmos-${local.solution_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  database_name       = "db_conversation_history"
  containers          = [{ name = "conversations", partition_key_path = "/userId" }]
}

module "app_service_plan" {
  source = "./modules/app-service-plan"

  name                = "asp-${local.solution_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku_name            = var.app_service_plan_sku
}

module "container_registry" {
  source = "./modules/container-registry"

  name                = local.container_registry_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = var.tags
}

module "backend_python" {
  source = "./modules/app-service"
  count  = var.backend_runtime_stack == "python" ? 1 : 0

  name                = "api-${local.solution_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  service_plan_id     = module.app_service_plan.resource_id
  linux_fx_version    = local.placeholder_container_image
  app_settings        = merge(local.backend_common_settings, { AZURE_SQLDB_USER_MID = "", AZURE_BASIC_LOGGING_LEVEL = "INFO", AZURE_PACKAGE_LOGGING_LEVEL = "WARNING", AZURE_LOGGING_PACKAGES = "" })
}

module "backend_dotnet" {
  source = "./modules/app-service"
  count  = var.backend_runtime_stack == "dotnet" ? 1 : 0

  name                = "api-cs-${local.solution_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  service_plan_id     = module.app_service_plan.resource_id
  linux_fx_version    = local.placeholder_container_image
  app_settings        = local.backend_common_settings
}

locals {
  backend_principal_id = var.backend_runtime_stack == "python" ? module.backend_python[0].identity_principal_id : module.backend_dotnet[0].identity_principal_id
  backend_app_url      = var.backend_runtime_stack == "python" ? module.backend_python[0].app_url : module.backend_dotnet[0].app_url
}

module "frontend" {
  source = "./modules/app-service"

  name                = "app-${local.solution_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  service_plan_id     = module.app_service_plan.resource_id
  linux_fx_version    = local.placeholder_container_image
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = module.app_insights.instrumentation_key
    APP_API_BASE_URL               = local.backend_app_url
    CHAT_LANDING_TEXT              = ""
    APP_TITLE_PRIMARY              = var.app_title_primary
    APP_TITLE_SECONDARY            = var.app_title_secondary
  }
}

module "role_assignments" {
  source = "./modules/role-assignments"

  subscription_id                      = var.subscription_id
  solution_name                        = local.solution_suffix
  use_existing_ai_project              = local.use_existing_ai_project
  existing_foundry_project_resource_id = var.existing_foundry_project_resource_id
  ai_project_principal_id              = local.ai_project_principal_id
  ai_search_principal_id               = module.ai_search.identity_principal_id
  backend_app_service_principal_id     = local.backend_principal_id
  frontend_app_service_principal_id    = module.frontend.identity_principal_id
  deployer_principal_id                = data.azurerm_client_config.current.object_id
  deployer_principal_type              = var.deploying_user_principal_type
  ai_foundry_resource_id               = local.use_existing_ai_project ? "" : local.ai_foundry_resource_id
  ai_search_resource_id                = module.ai_search.resource_id
  storage_account_resource_id          = module.storage_account.resource_id
  cosmos_db_account_id                 = module.cosmos_db.resource_id
  container_registry_resource_id       = module.container_registry.resource_id
}