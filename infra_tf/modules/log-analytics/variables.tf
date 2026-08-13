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
variable "retention_in_days" {
  type    = number
  default = 365
}
variable "sku_name" {
  type    = string
  default = "PerGB2018"
}