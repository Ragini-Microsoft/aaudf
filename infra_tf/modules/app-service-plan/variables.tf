variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
variable "sku_name" {
  type    = string
  default = "B2"
}
variable "worker_count" {
  type    = number
  default = 1
}
variable "zone_balancing_enabled" {
  type    = bool
  default = false
}