output "assignment_ids" {
  value = concat(
    azurerm_role_assignment.search_openai_user_new[*].id,
    azurerm_role_assignment.search_openai_user_existing[*].id,
    azurerm_role_assignment.backend_foundry_user_new[*].id,
    azurerm_role_assignment.backend_foundry_user_existing[*].id,
    [
      azurerm_role_assignment.project_search_reader.id,
      azurerm_role_assignment.project_search_contributor.id,
      azurerm_role_assignment.backend_search_reader.id,
      azurerm_role_assignment.project_storage_contributor.id,
      azurerm_role_assignment.project_storage_reader.id,
      azurerm_role_assignment.search_storage_reader.id,
      azurerm_cosmosdb_sql_role_assignment.backend_data_contributor.id,
      azurerm_role_assignment.deployer_search_index_contributor.id,
      azurerm_role_assignment.deployer_search_service_contributor.id,
      azurerm_role_assignment.deployer_storage_contributor.id,
      azurerm_role_assignment.backend_acr_pull.id,
      azurerm_role_assignment.frontend_acr_pull.id
    ],
    azurerm_role_assignment.deployer_cognitive_services_user[*].id,
    azurerm_role_assignment.deployer_foundry_user[*].id
  )
}