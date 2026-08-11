resource "azurerm_role_assignment" "main" {
  scope              = var.scope
  principal_id       = var.principal_id
  role_definition_id = var.role_definition_id
  principal_type     = var.principal_type
}