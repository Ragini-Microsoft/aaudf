locals {
  existing_project_parts = split("/", var.existing_foundry_project_resource_id)
  existing_foundry_id    = var.use_existing_ai_project ? join("/", slice(local.existing_project_parts, 0, 9)) : ""
  foundry_scope          = var.use_existing_ai_project ? local.existing_foundry_id : var.ai_foundry_resource_id
  role_definitions = {
    azure_ai_user                  = "53ca6127-db72-4b80-b1b0-d745d6d5456d"
    cognitive_services_user        = "a97b65f3-24c7-4388-baec-2e87135dc908"
    cognitive_services_openai_user = "5e0bd9bd-7b93-4f28-af87-19fc36ad61bd"
    search_index_data_reader       = "1407120a-92aa-4202-b7e9-c0e197c71c8f"
    search_index_data_contributor  = "8ebe5a00-799e-43f5-93ac-243d3dce84a7"
    search_service_contributor     = "7ca78c08-252a-4471-8644-bb5ff32d4ba0"
    storage_blob_data_contributor  = "ba92f5b4-2d11-453d-a403-e96b0029c9fe"
    storage_blob_data_reader       = "2a2b9908-6ea1-4ae2-8e65-a410df84e7d1"
    acr_pull                       = "7f951dda-4ed3-4680-a7ca-43fe172d538d"
  }
  role_definition_ids = {
    for key, value in local.role_definitions : key => "/subscriptions/${var.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${value}"
  }
}

resource "azurerm_role_assignment" "search_openai_user" {
  count = local.foundry_scope != "" && var.ai_search_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${local.foundry_scope}:${var.ai_search_principal_id}:${local.role_definitions.cognitive_services_openai_user}")
  scope              = local.foundry_scope
  principal_id       = var.ai_search_principal_id
  role_definition_id = local.role_definition_ids.cognitive_services_openai_user
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "backend_foundry_user" {
  count = local.foundry_scope != "" && var.backend_app_service_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${local.foundry_scope}:${var.backend_app_service_principal_id}:${local.role_definitions.azure_ai_user}")
  scope              = local.foundry_scope
  principal_id       = var.backend_app_service_principal_id
  role_definition_id = local.role_definition_ids.azure_ai_user
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "project_search_reader" {
  count = var.ai_search_resource_id != "" && var.ai_project_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.ai_search_resource_id}:${var.ai_project_principal_id}:${local.role_definitions.search_index_data_reader}")
  scope              = var.ai_search_resource_id
  principal_id       = var.ai_project_principal_id
  role_definition_id = local.role_definition_ids.search_index_data_reader
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "project_search_contributor" {
  count = var.ai_search_resource_id != "" && var.ai_project_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.ai_search_resource_id}:${var.ai_project_principal_id}:${local.role_definitions.search_service_contributor}")
  scope              = var.ai_search_resource_id
  principal_id       = var.ai_project_principal_id
  role_definition_id = local.role_definition_ids.search_service_contributor
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "backend_search_reader" {
  count = var.ai_search_resource_id != "" && var.backend_app_service_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.ai_search_resource_id}:${var.backend_app_service_principal_id}:${local.role_definitions.search_index_data_reader}")
  scope              = var.ai_search_resource_id
  principal_id       = var.backend_app_service_principal_id
  role_definition_id = local.role_definition_ids.search_index_data_reader
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "project_storage_contributor" {
  count = var.storage_account_resource_id != "" && var.ai_project_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.storage_account_resource_id}:${var.ai_project_principal_id}:${local.role_definitions.storage_blob_data_contributor}")
  scope              = var.storage_account_resource_id
  principal_id       = var.ai_project_principal_id
  role_definition_id = local.role_definition_ids.storage_blob_data_contributor
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "project_storage_reader" {
  count = var.storage_account_resource_id != "" && var.ai_project_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.storage_account_resource_id}:${var.ai_project_principal_id}:${local.role_definitions.storage_blob_data_reader}")
  scope              = var.storage_account_resource_id
  principal_id       = var.ai_project_principal_id
  role_definition_id = local.role_definition_ids.storage_blob_data_reader
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "search_storage_reader" {
  count = var.storage_account_resource_id != "" && var.ai_search_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.storage_account_resource_id}:${var.ai_search_principal_id}:${local.role_definitions.storage_blob_data_reader}")
  scope              = var.storage_account_resource_id
  principal_id       = var.ai_search_principal_id
  role_definition_id = local.role_definition_ids.storage_blob_data_reader
  principal_type     = "ServicePrincipal"
}

resource "azapi_resource" "backend_cosmos_contributor" {
  count = var.cosmos_db_account_id != "" && var.backend_app_service_principal_id != "" ? 1 : 0

  type                      = "Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2025-10-15"
  name                      = uuidv5("dns", "${var.solution_name}:${var.cosmos_db_account_id}:${var.backend_app_service_principal_id}:cosmos-data-contributor")
  parent_id                 = var.cosmos_db_account_id
  schema_validation_enabled = false
  body = {
    properties = {
      principalId      = var.backend_app_service_principal_id
      roleDefinitionId = "${var.cosmos_db_account_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
      scope            = var.cosmos_db_account_id
    }
  }
}

resource "azurerm_role_assignment" "deployer_ai_services_user" {
  count = !var.use_existing_ai_project && var.ai_foundry_resource_id != "" && var.deployer_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.ai_foundry_resource_id}:${var.deployer_principal_id}:${local.role_definitions.cognitive_services_user}")
  scope              = var.ai_foundry_resource_id
  principal_id       = var.deployer_principal_id
  role_definition_id = local.role_definition_ids.cognitive_services_user
  principal_type     = var.deployer_principal_type
}

resource "azurerm_role_assignment" "deployer_foundry_user" {
  count = !var.use_existing_ai_project && var.ai_foundry_resource_id != "" && var.deployer_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.ai_foundry_resource_id}:${var.deployer_principal_id}:${local.role_definitions.azure_ai_user}")
  scope              = var.ai_foundry_resource_id
  principal_id       = var.deployer_principal_id
  role_definition_id = local.role_definition_ids.azure_ai_user
  principal_type     = var.deployer_principal_type
}

resource "azurerm_role_assignment" "deployer_search_index_contributor" {
  count = var.ai_search_resource_id != "" && var.deployer_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.ai_search_resource_id}:${var.deployer_principal_id}:${local.role_definitions.search_index_data_contributor}")
  scope              = var.ai_search_resource_id
  principal_id       = var.deployer_principal_id
  role_definition_id = local.role_definition_ids.search_index_data_contributor
  principal_type     = var.deployer_principal_type
}

resource "azurerm_role_assignment" "deployer_search_service_contributor" {
  count = var.ai_search_resource_id != "" && var.deployer_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.ai_search_resource_id}:${var.deployer_principal_id}:${local.role_definitions.search_service_contributor}")
  scope              = var.ai_search_resource_id
  principal_id       = var.deployer_principal_id
  role_definition_id = local.role_definition_ids.search_service_contributor
  principal_type     = var.deployer_principal_type
}

resource "azurerm_role_assignment" "deployer_storage_contributor" {
  count = var.storage_account_resource_id != "" && var.deployer_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.storage_account_resource_id}:${var.deployer_principal_id}:${local.role_definitions.storage_blob_data_contributor}")
  scope              = var.storage_account_resource_id
  principal_id       = var.deployer_principal_id
  role_definition_id = local.role_definition_ids.storage_blob_data_contributor
  principal_type     = var.deployer_principal_type
}

resource "azurerm_role_assignment" "backend_acr_pull" {
  count = var.container_registry_resource_id != "" && var.backend_app_service_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.container_registry_resource_id}:${var.backend_app_service_principal_id}:${local.role_definitions.acr_pull}")
  scope              = var.container_registry_resource_id
  principal_id       = var.backend_app_service_principal_id
  role_definition_id = local.role_definition_ids.acr_pull
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "frontend_acr_pull" {
  count = var.container_registry_resource_id != "" && var.frontend_app_service_principal_id != "" ? 1 : 0

  name               = uuidv5("dns", "${var.solution_name}:${var.container_registry_resource_id}:${var.frontend_app_service_principal_id}:${local.role_definitions.acr_pull}")
  scope              = var.container_registry_resource_id
  principal_id       = var.frontend_app_service_principal_id
  role_definition_id = local.role_definition_ids.acr_pull
  principal_type     = "ServicePrincipal"
}