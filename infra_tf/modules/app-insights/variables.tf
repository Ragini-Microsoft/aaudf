variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "workspace_resource_id" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
variable "application_type" {
  type    = string
  default = "web"
}
variable "retention_in_days" {
  type    = number
  default = 365
}
variable "disable_ip_masking" {
  type    = bool
  default = false
}