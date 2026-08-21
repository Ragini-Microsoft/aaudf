variable "resource_group_name" { type = string }
variable "solution_name" { type = string }
variable "name" {
  type    = string
  default = null
}
variable "location" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
variable "sku" {
  type    = string
  default = "Standard"
}
variable "admin_user_enabled" {
  type    = bool
  default = false
}
variable "public_network_access" {
  type    = string
  default = "Enabled"
}
variable "export_policy_enabled" {
  type    = bool
  default = true
}