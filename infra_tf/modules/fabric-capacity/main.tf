data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azapi_resource" "main" {
  type                      = "Microsoft.Fabric/capacities@2023-11-01"
  name                      = var.name
  parent_id                 = data.azurerm_resource_group.main.id
  location                  = var.location
  tags                      = var.tags
  schema_validation_enabled = false
  body = {
    sku        = { name = var.sku_name, tier = "Fabric" }
    properties = { administration = { members = var.admin_members } }
  }
}