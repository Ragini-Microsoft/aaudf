output "assignment_ids" {
  value = compact([
    try(azurerm_role_assignment.search_openai_user[0].id, ""),
    try(azurerm_role_assignment.backend_foundry_user[0].id, ""),
    try(azurerm_role_assignment.project_search_reader[0].id, ""),
    try(azurerm_role_assignment.project_search_contributor[0].id, ""),
    try(azurerm_role_assignment.backend_search_reader[0].id, ""),
    try(azurerm_role_assignment.project_storage_contributor[0].id, ""),
    try(azurerm_role_assignment.project_storage_reader[0].id, ""),
    try(azurerm_role_assignment.search_storage_reader[0].id, ""),
    try(azapi_resource.backend_cosmos_contributor[0].id, ""),
    try(azurerm_role_assignment.deployer_ai_services_user[0].id, ""),
    try(azurerm_role_assignment.deployer_foundry_user[0].id, ""),
    try(azurerm_role_assignment.deployer_search_index_contributor[0].id, ""),
    try(azurerm_role_assignment.deployer_search_service_contributor[0].id, ""),
    try(azurerm_role_assignment.deployer_storage_contributor[0].id, ""),
    try(azurerm_role_assignment.backend_acr_pull[0].id, ""),
    try(azurerm_role_assignment.frontend_acr_pull[0].id, "")
  ])
}