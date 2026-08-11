output "solution_name" {
  description = "Solution suffix used for resource naming"
  value       = local.solution_suffix
}

output "resource_group_name" {
  description = "Name of the deployed resource group"
  value       = azurerm_resource_group.main.name
}

output "deployment_flavor" {
  description = "Deployment flavor used"
  value       = var.deployment_flavor
}

output "deployment_type" {
  description = "WAF deployment type"
  value       = "N/A"
}

output "azure_env_container_registry_name" {
  description = "Name of the dedicated Azure Container Registry"
  value       = module.container_registry.name
}

output "azure_container_registry_endpoint" {
  description = "Login server of the dedicated Azure Container Registry"
  value       = module.container_registry.login_server
}

output "azure_env_image_tag" {
  description = "Docker image tag used for application deployment"
  value       = var.image_tag
}

output "azure_cosmosdb_account" {
  description = "Cosmos DB account name"
  value       = module.cosmos_db.name
}

output "azure_cosmosdb_conversations_container" {
  description = "Cosmos DB conversations container name"
  value       = "conversations"
}

output "azure_cosmosdb_database" {
  description = "Cosmos DB database name"
  value       = "db_conversation_history"
}

output "azure_env_gpt_model_name" {
  description = "GPT model deployment name"
  value       = var.gpt_model_name
}

output "azure_openai_endpoint" {
  description = "Azure OpenAI endpoint"
  value       = local.ai_foundry_endpoint
}

output "azure_env_embedding_deployment_name" {
  description = "Embedding model deployment name"
  value       = var.embedding_model
}

output "azure_sqldb_user_mid" {
  description = "Managed identity client ID for SQL authentication"
  value       = ""
}

output "api_uid" {
  description = "Backend API managed identity client ID"
  value       = ""
}

output "azure_ai_agent_endpoint" {
  description = "Azure AI Agent endpoint"
  value       = local.ai_project_endpoint
}

output "azure_ai_agent_model_deployment_name" {
  description = "Model deployment used by Azure AI Agent"
  value       = var.gpt_model_name
}

output "api_app_name" {
  description = "Backend API App Service name"
  value       = local.backend_name
}

output "api_pid" {
  description = "Backend API managed identity principal ID"
  value       = local.backend_principal_id
}

output "mid_display_name" {
  description = "Backend API managed identity display name"
  value       = local.backend_name
}

output "web_app_name" {
  description = "Frontend web application name"
  value       = module.frontend.name
}

output "web_app_url" {
  description = "Frontend web application URL"
  value       = module.frontend.app_url
}

output "azure_ai_search_endpoint" {
  description = "Azure AI Search endpoint"
  value       = module.ai_search.endpoint
}

output "azure_ai_search_index" {
  description = "Azure AI Search index name"
  value       = "knowledge_index"
}

output "azure_ai_search_name" {
  description = "Azure AI Search service name"
  value       = module.ai_search.name
}

output "search_data_folder" {
  description = "Search data folder path"
  value       = "data/default/documents"
}

output "azure_ai_search_connection_name" {
  description = "AI Search connection name"
  value       = module.foundry_search_connection.connection_name
}

output "azure_ai_search_connection_id" {
  description = "AI Search connection resource ID"
  value       = module.foundry_search_connection.connection_id
}

output "azure_ai_project_endpoint" {
  description = "AI Foundry project endpoint"
  value       = local.ai_project_endpoint
}

output "ai_foundry_resource_id" {
  description = "AI Foundry account resource ID"
  value       = local.ai_foundry_resource_id
}

output "azure_ai_project_name" {
  description = "AI Foundry project name"
  value       = local.ai_project_name
}

output "ai_service_name" {
  description = "AI Services account name"
  value       = local.ai_foundry_name
}

output "foundry_project_pid" {
  description = "AI Foundry project managed identity principal ID"
  value       = local.ai_project_principal_id
}

output "use_chat_history_enabled" {
  description = "Chat history enabled flag"
  value       = local.use_chat_history_setting
}

output "backend_runtime_stack" {
  description = "Backend runtime stack"
  value       = var.backend_runtime_stack
}

output "use_user_access_token" {
  description = "User access token forwarding flag"
  value       = local.use_user_access_token_setting
}

output "azure_fabric_capacity_resource_id" {
  description = "Fabric capacity resource ID"
  value       = local.create_fabric_workspace ? (local.should_create_fabric_capacity ? module.fabric_capacity[0].resource_id : "") : ""
}

output "azure_fabric_capacity_name" {
  description = "Fabric capacity resource name"
  value       = local.create_fabric_workspace ? local.fabric_capacity_name : ""
}

output "fabric_admin_members" {
  description = "Fabric capacity administrator identities"
  value       = local.should_create_fabric_capacity ? local.fabric_admin_members : []
}

output "create_fabric_workspace" {
  description = "Whether Fabric workspace creation is enabled"
  value       = local.create_fabric_workspace
}

output "fabric_workspace_id" {
  description = "Existing Fabric workspace ID"
  value       = var.fabric_workspace_id
}