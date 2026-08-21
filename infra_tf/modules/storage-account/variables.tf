variable "resource_group_name" { type = string }
variable "solution_name" { type = string }
variable "location" { type = string }
variable "name" {
  type    = string
  default = null
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "sku_name" {
  type    = string
  default = "Standard_LRS"
}
variable "kind" {
  type    = string
  default = "StorageV2"
}
variable "access_tier" {
  type    = string
  default = "Hot"
}
variable "allow_blob_public_access" {
  type    = bool
  default = false
}
variable "allow_shared_key_access" {
  type    = bool
  default = true
}
variable "enable_hierarchical_namespace" {
  type    = bool
  default = false
}
variable "containers" {
  type    = list(object({ name = string, public_access = string }))
  default = [{ name = "default", public_access = "None" }]
}