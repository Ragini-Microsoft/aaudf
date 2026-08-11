variable "name" { type = string }
variable "resource_group_name" { type = string }
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