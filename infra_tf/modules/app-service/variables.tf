variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "service_plan_id" { type = string }
variable "linux_fx_version" { type = string }
variable "app_settings" {
  type      = map(string)
  default   = {}
  sensitive = true
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "always_on" {
  type    = bool
  default = true
}
variable "health_check_path" {
  type    = string
  default = ""
}
variable "web_sockets_enabled" {
  type    = bool
  default = false
}
variable "app_command_line" {
  type    = string
  default = ""
}
variable "public_network_access" {
  type    = string
  default = "Enabled"
}
variable "acr_use_managed_identity_credentials" {
  type    = bool
  default = true
}