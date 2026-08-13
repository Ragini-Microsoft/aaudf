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
variable "sku_name" {
  type    = string
  default = "B2"
}
variable "worker_count" {
  type    = number
  default = 1
}
variable "zone_redundant" {
  type    = bool
  default = false
}