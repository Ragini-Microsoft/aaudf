variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
variable "sku_name" {
  type    = string
  default = "basic"
}
variable "replica_count" {
  type    = number
  default = 1
}
variable "partition_count" {
  type    = number
  default = 1
}
variable "hosting_mode" {
  type    = string
  default = "default"
}
variable "semantic_search" {
  type    = string
  default = "free"
}
variable "disable_local_auth" {
  type    = bool
  default = true
}
variable "public_network_access" {
  type    = string
  default = "Enabled"
}