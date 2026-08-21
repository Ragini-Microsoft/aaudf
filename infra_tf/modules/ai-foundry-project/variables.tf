variable "resource_group_id" { type = string }
variable "solution_name" { type = string }
variable "name" {
  type    = string
  default = null
}
variable "project_name" {
  type    = string
  default = null
}
variable "location" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
variable "sku_name" {
  type    = string
  default = "S0"
}
variable "disable_local_auth" {
  type    = bool
  default = true
}
variable "allow_project_management" {
  type    = bool
  default = true
}
variable "public_network_access" {
  type    = string
  default = "Enabled"
}
variable "network_acls_default_action" {
  type    = string
  default = "Allow"
}