locals {
  roles = {
    azure_ai_user                  = "53ca6127-db72-4b80-b1b0-d745d6d5456d"
    cognitive_services_user        = "a97b65f3-24c7-4388-baec-2e87135dc908"
    cognitive_services_openai_user = "5e0bd9bd-7b93-4f28-af87-19fc36ad61bd"
    search_index_data_reader       = "1407120a-92aa-4202-b7e9-c0e197c71c8f"
    search_index_data_contributor  = "8ebe5a00-799e-43f5-93ac-243d3dce84a7"
    search_service_contributor     = "7ca78c08-252a-4471-8644-bb5ff32d4ba0"
    storage_blob_data_contributor  = "ba92f5b4-2d11-453d-a403-e96b0029c9fe"
    storage_blob_data_reader       = "2a2b9908-6ea1-4ae2-8e65-a410df84e7d1"
    acr_pull                       = "7f951dda-4ed3-4680-a7ca-43fe172d538d"
    cosmos_db_data_contributor     = "00000000-0000-0000-0000-000000000002"
  }
}

resource "azurerm_role_assignment" "search_openai_user_new" {
  count              = var.use_existing_ai_project ? 0 : 1
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.ai_foundry_resource_id}-${var.ai_search_principal_id}-${local.roles.cognitive_services_openai_user}")
  scope              = var.ai_foundry_resource_id
  role_definition_id = "/subscriptions/${split("/", var.ai_foundry_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.cognitive_services_openai_user}"
  principal_id       = var.ai_search_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "search_openai_user_existing" {
  count              = var.use_existing_ai_project ? 1 : 0
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.ai_foundry_resource_id}-${var.ai_search_principal_id}-${local.roles.cognitive_services_openai_user}")
  scope              = var.ai_foundry_resource_id
  role_definition_id = "/subscriptions/${split("/", var.ai_foundry_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.cognitive_services_openai_user}"
  principal_id       = var.ai_search_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "backend_foundry_user_new" {
  count              = var.use_existing_ai_project ? 0 : 1
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.ai_foundry_resource_id}-${var.backend_app_service_principal_id}-${local.roles.azure_ai_user}")
  scope              = var.ai_foundry_resource_id
  role_definition_id = "/subscriptions/${split("/", var.ai_foundry_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.azure_ai_user}"
  principal_id       = var.backend_app_service_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "backend_foundry_user_existing" {
  count              = var.use_existing_ai_project ? 1 : 0
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.ai_foundry_resource_id}-${var.backend_app_service_principal_id}-${local.roles.azure_ai_user}")
  scope              = var.ai_foundry_resource_id
  role_definition_id = "/subscriptions/${split("/", var.ai_foundry_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.azure_ai_user}"
  principal_id       = var.backend_app_service_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "project_search_reader" {
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.ai_search_resource_id}-${var.ai_project_principal_id}-${local.roles.search_index_data_reader}")
  scope              = var.ai_search_resource_id
  role_definition_id = "/subscriptions/${split("/", var.ai_search_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.search_index_data_reader}"
  principal_id       = var.ai_project_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "project_search_contributor" {
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.ai_search_resource_id}-${var.ai_project_principal_id}-${local.roles.search_service_contributor}")
  scope              = var.ai_search_resource_id
  role_definition_id = "/subscriptions/${split("/", var.ai_search_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.search_service_contributor}"
  principal_id       = var.ai_project_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "backend_search_reader" {
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.ai_search_resource_id}-${var.backend_app_service_principal_id}-${local.roles.search_index_data_reader}")
  scope              = var.ai_search_resource_id
  role_definition_id = "/subscriptions/${split("/", var.ai_search_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.search_index_data_reader}"
  principal_id       = var.backend_app_service_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "project_storage_contributor" {
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.storage_account_resource_id}-${var.ai_project_principal_id}-${local.roles.storage_blob_data_contributor}")
  scope              = var.storage_account_resource_id
  role_definition_id = "/subscriptions/${split("/", var.storage_account_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.storage_blob_data_contributor}"
  principal_id       = var.ai_project_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "project_storage_reader" {
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.storage_account_resource_id}-${var.ai_project_principal_id}-${local.roles.storage_blob_data_reader}")
  scope              = var.storage_account_resource_id
  role_definition_id = "/subscriptions/${split("/", var.storage_account_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.storage_blob_data_reader}"
  principal_id       = var.ai_project_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "search_storage_reader" {
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.storage_account_resource_id}-${var.ai_search_principal_id}-${local.roles.storage_blob_data_reader}")
  scope              = var.storage_account_resource_id
  role_definition_id = "/subscriptions/${split("/", var.storage_account_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.storage_blob_data_reader}"
  principal_id       = var.ai_search_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_cosmosdb_sql_role_assignment" "backend_data_contributor" {
  name                = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.cosmos_db_account_id}-${var.backend_app_service_principal_id}-${local.roles.cosmos_db_data_contributor}")
  resource_group_name = split("/", var.cosmos_db_account_id)[4]
  account_name        = split("/", var.cosmos_db_account_id)[8]
  role_definition_id  = "${var.cosmos_db_account_id}/sqlRoleDefinitions/${local.roles.cosmos_db_data_contributor}"
  principal_id        = var.backend_app_service_principal_id
  scope               = var.cosmos_db_account_id
}

resource "azurerm_role_assignment" "deployer_cognitive_services_user" {
  count              = var.use_existing_ai_project ? 0 : 1
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.ai_foundry_resource_id}-${var.deployer_principal_id}-${local.roles.cognitive_services_user}")
  scope              = var.ai_foundry_resource_id
  role_definition_id = "/subscriptions/${split("/", var.ai_foundry_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.cognitive_services_user}"
  principal_id       = var.deployer_principal_id
  principal_type     = var.deployer_principal_type
}

resource "azurerm_role_assignment" "deployer_foundry_user" {
  count              = var.use_existing_ai_project ? 0 : 1
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.ai_foundry_resource_id}-${var.deployer_principal_id}-${local.roles.azure_ai_user}")
  scope              = var.ai_foundry_resource_id
  role_definition_id = "/subscriptions/${split("/", var.ai_foundry_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.azure_ai_user}"
  principal_id       = var.deployer_principal_id
  principal_type     = var.deployer_principal_type
}

resource "azurerm_role_assignment" "deployer_search_index_contributor" {
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.ai_search_resource_id}-${var.deployer_principal_id}-${local.roles.search_index_data_contributor}")
  scope              = var.ai_search_resource_id
  role_definition_id = "/subscriptions/${split("/", var.ai_search_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.search_index_data_contributor}"
  principal_id       = var.deployer_principal_id
  principal_type     = var.deployer_principal_type
}

resource "azurerm_role_assignment" "deployer_search_service_contributor" {
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.ai_search_resource_id}-${var.deployer_principal_id}-${local.roles.search_service_contributor}")
  scope              = var.ai_search_resource_id
  role_definition_id = "/subscriptions/${split("/", var.ai_search_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.search_service_contributor}"
  principal_id       = var.deployer_principal_id
  principal_type     = var.deployer_principal_type
}

resource "azurerm_role_assignment" "deployer_storage_contributor" {
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.storage_account_resource_id}-${var.deployer_principal_id}-${local.roles.storage_blob_data_contributor}")
  scope              = var.storage_account_resource_id
  role_definition_id = "/subscriptions/${split("/", var.storage_account_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.storage_blob_data_contributor}"
  principal_id       = var.deployer_principal_id
  principal_type     = var.deployer_principal_type
}

resource "azurerm_role_assignment" "backend_acr_pull" {
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.container_registry_resource_id}-${var.backend_app_service_principal_id}-${local.roles.acr_pull}")
  scope              = var.container_registry_resource_id
  role_definition_id = "/subscriptions/${split("/", var.container_registry_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.acr_pull}"
  principal_id       = var.backend_app_service_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "frontend_acr_pull" {
  name               = uuidv5("11fb06fb-712d-4ddd-98c7-e71bbd588830", "${var.solution_name}-${var.container_registry_resource_id}-${var.frontend_app_service_principal_id}-${local.roles.acr_pull}")
  scope              = var.container_registry_resource_id
  role_definition_id = "/subscriptions/${split("/", var.container_registry_resource_id)[2]}/providers/Microsoft.Authorization/roleDefinitions/${local.roles.acr_pull}"
  principal_id       = var.frontend_app_service_principal_id
  principal_type     = "ServicePrincipal"
}