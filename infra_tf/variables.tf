variable "subscription_id" {
  description = "Azure subscription ID used by the provider"
  type        = string
}

variable "deployment_flavor" {
  description = "Deployment flavor selected for this Terraform port"
  type        = string
  default     = "bicep"

  validation {
    condition     = var.deployment_flavor == "bicep"
    error_message = "This Terraform port supports only the bicep deployment flavor."
  }
}

variable "resource_group_name" {
  description = "Target resource group name"
  type        = string
  default     = ""
}

variable "solution_name" {
  description = "Application name used as the base for resource naming"
  type        = string
  default     = "agenticappudf"

  validation {
    condition     = length(var.solution_name) >= 3 && length(var.solution_name) <= 20
    error_message = "solution_name must contain between 3 and 20 characters."
  }
}

variable "solution_unique_text" {
  description = "Optional unique text appended to resource names"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.solution_unique_text == null || length(var.solution_unique_text) <= 5
    error_message = "solution_unique_text must contain at most 5 characters."
  }
}

variable "location" {
  description = "Primary Azure region for resource deployment"
  type        = string
  default     = null
  nullable    = true
}

variable "azure_ai_service_location" {
  description = "Azure region for AI Foundry and model deployments"
  type        = string

  validation {
    condition = contains([
      "australiaeast", "eastus", "eastus2", "francecentral", "japaneast",
      "swedencentral", "uksouth", "westus", "westus3"
    ], var.azure_ai_service_location)
    error_message = "azure_ai_service_location must be one of the regions supported by the Bicep template."
  }
}

variable "deployment_type" {
  description = "GPT model deployment type"
  type        = string
  default     = "GlobalStandard"

  validation {
    condition     = contains(["Standard", "GlobalStandard"], var.deployment_type)
    error_message = "deployment_type must be Standard or GlobalStandard."
  }
}

variable "gpt_model_name" {
  description = "GPT model deployment name"
  type        = string
  default     = "gpt-5.4-mini"
}

variable "gpt_model_version" {
  description = "GPT model version"
  type        = string
  default     = "2026-03-17"
}

variable "azure_openai_api_version" {
  description = "Azure OpenAI API version"
  type        = string
  default     = "2025-01-01-preview"
}

variable "azure_ai_agent_api_version" {
  description = "Azure AI Agent API version"
  type        = string
  default     = "2025-05-01"
}

variable "gpt_deployment_capacity" {
  description = "GPT deployment capacity in thousands of tokens per minute"
  type        = number
  default     = 150

  validation {
    condition     = var.gpt_deployment_capacity >= 10
    error_message = "gpt_deployment_capacity must be at least 10."
  }
}

variable "embedding_model" {
  description = "Embedding model deployment name"
  type        = string
  default     = "text-embedding-3-small"

  validation {
    condition     = var.embedding_model == "text-embedding-3-small"
    error_message = "embedding_model must be text-embedding-3-small."
  }
}

variable "embedding_deployment_capacity" {
  description = "Embedding deployment capacity"
  type        = number
  default     = 80

  validation {
    condition     = var.embedding_deployment_capacity >= 10
    error_message = "embedding_deployment_capacity must be at least 10."
  }
}

variable "image_tag" {
  description = "Docker image tag for application deployments"
  type        = string
  default     = "latest_v3"
}

variable "container_registry_name" {
  description = "Optional existing naming override for Azure Container Registry"
  type        = string
  default     = ""
}

variable "backend_runtime_stack" {
  description = "Backend runtime stack"
  type        = string
  default     = "python"

  validation {
    condition     = contains(["python", "dotnet"], var.backend_runtime_stack)
    error_message = "backend_runtime_stack must be python or dotnet."
  }
}

variable "app_service_plan_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "B2"

  validation {
    condition = contains([
      "F1", "D1", "B1", "B2", "B3", "S1", "S2", "S3", "P1", "P2", "P3", "P1v3", "P1v4"
    ], var.app_service_plan_sku)
    error_message = "app_service_plan_sku must be one of the values accepted by the Bicep router."
  }
}

variable "use_chat_history_enabled" {
  description = "Whether chat history storage is enabled"
  type        = bool
  default     = true
}

variable "use_user_access_token" {
  description = "Whether user access tokens are forwarded"
  type        = bool
  default     = true
}

variable "existing_log_analytics_workspace_id" {
  description = "Resource ID of an existing Log Analytics workspace"
  type        = string
  default     = ""
}

variable "existing_foundry_project_resource_id" {
  description = "Resource ID of an existing AI Foundry project"
  type        = string
  default     = ""
}

variable "deploying_user_principal_type" {
  description = "Principal type of the deploying identity"
  type        = string
  default     = "User"

  validation {
    condition     = contains(["User", "ServicePrincipal"], var.deploying_user_principal_type)
    error_message = "deploying_user_principal_type must be User or ServicePrincipal."
  }
}

variable "app_title_primary" {
  description = "Primary title displayed by the web application"
  type        = string
  default     = "Contoso"
}

variable "app_title_secondary" {
  description = "Secondary title displayed by the web application"
  type        = string
  default     = "| Unified Data Analysis Agents"
}

variable "tags" {
  description = "Tags applied to deployed resources"
  type        = map(string)
  default     = {}
}

variable "enable_telemetry" {
  description = "AVM telemetry flag retained from the router contract"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "AVM monitoring flag retained from the router contract"
  type        = bool
  default     = false
}

variable "enable_private_networking" {
  description = "AVM private networking flag retained from the router contract"
  type        = bool
  default     = false
}

variable "enable_scalability" {
  description = "AVM scalability flag retained from the router contract"
  type        = bool
  default     = false
}

variable "enable_redundancy" {
  description = "AVM redundancy flag retained from the router contract"
  type        = bool
  default     = false
}

variable "fabric_workspace_id" {
  description = "Existing Fabric workspace ID"
  type        = string
  default     = ""
}

variable "azure_fabric_capacity_name" {
  description = "Existing Fabric capacity name"
  type        = string
  default     = ""
}

variable "fabric_capacity_sku" {
  description = "Fabric capacity SKU"
  type        = string
  default     = "F2"

  validation {
    condition = contains([
      "F2", "F4", "F8", "F16", "F32", "F64", "F128", "F256", "F512", "F1024", "F2048"
    ], var.fabric_capacity_sku)
    error_message = "fabric_capacity_sku must be a supported Fabric F SKU."
  }
}

variable "fabric_admin_members" {
  description = "Additional Fabric capacity administrator object IDs"
  type        = list(string)
  default     = []
}

variable "vm_admin_username" {
  description = "AVM-WAF VM administrator username retained from the router contract"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "vm_admin_password" {
  description = "AVM-WAF VM administrator password retained from the router contract"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "vm_size" {
  description = "AVM-WAF jumpbox VM size retained from the router contract"
  type        = string
  default     = "Standard_D2s_v5"
}