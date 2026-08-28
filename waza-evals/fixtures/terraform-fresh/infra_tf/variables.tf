variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "solution_name" {
  description = "Application name for resource naming"
  type        = string
  default     = "myapp"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "ai_service_location" {
  description = "AI Foundry region"
  type        = string
  default     = "eastus"
}
