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
variable "database_name" {
  type    = string
  default = "db_conversation_history"
}
variable "containers" {
  type    = list(object({ name = string, partition_key_path = string }))
  default = [{ name = "conversations", partition_key_path = "/userId" }]
}