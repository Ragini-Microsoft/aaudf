variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
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