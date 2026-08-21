variable "solution_name" { type = string }
variable "use_existing_ai_project" {
  type    = bool
  default = false
}
variable "ai_project_principal_id" { type = string }
variable "ai_search_principal_id" { type = string }
variable "backend_app_service_principal_id" { type = string }
variable "frontend_app_service_principal_id" { type = string }
variable "deployer_principal_id" { type = string }
variable "deployer_principal_type" {
  type    = string
  default = "User"
}
variable "ai_foundry_resource_id" { type = string }
variable "ai_search_resource_id" { type = string }
variable "storage_account_resource_id" { type = string }
variable "cosmos_db_account_id" { type = string }
variable "container_registry_resource_id" { type = string }