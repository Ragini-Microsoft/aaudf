variable "account_id" { type = string }
variable "account_name" { type = string }
variable "deployment_name" { type = string }
variable "model_format" {
  type    = string
  default = "OpenAI"
}
variable "model_name" { type = string }
variable "model_version" {
  type    = string
  default = ""
}
variable "rai_policy_name" {
  type    = string
  default = "Microsoft.Default"
}
variable "sku_name" { type = string }
variable "sku_capacity" { type = number }