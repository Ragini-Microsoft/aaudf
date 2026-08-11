variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
variable "sku" {
  type    = string
  default = "Standard"
}
variable "admin_enabled" {
  type    = bool
  default = false
}
variable "public_network_access_enabled" {
  type    = bool
  default = true
}