variable "account_name" { type = string }
variable "project_name" { type = string }
variable "resource_group_id" { type = string }
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