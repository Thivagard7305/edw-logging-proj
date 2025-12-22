########################################
# DEVELOPMENT ENVIRONMENT - Variables
# File: environments/dev/variables.tf
########################################

# Simply redeclare all variables that will be passed to the module
# This allows you to use terraform.tfvars files

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "create_resource_group" {
  description = "Create new resource group"
  type        = bool
  default     = true
}

variable "resource_group_tags" {
  description = "Resource group tags"
  type        = map(string)
  default     = {}
}

variable "log_analytics_sku" {
  description = "Log Analytics SKU"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_days" {
  description = "Log retention days"
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Daily quota in GB"
  type        = number
  default     = -1
}

variable "internet_ingestion_enabled" {
  description = "Enable internet ingestion"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Enable internet query"
  type        = bool
  default     = true
}

variable "log_analytics_tags" {
  description = "Log Analytics tags"
  type        = map(string)
  default     = {}
}

variable "enable_container_insights" {
  description = "Enable Container Insights"
  type        = bool
  default     = false
}

variable "enable_security_center" {
  description = "Enable Security Center"
  type        = bool
  default     = true
}

variable "enable_azure_activity" {
  description = "Enable Azure Activity"
  type        = bool
  default     = true
}

variable "enable_vm_insights" {
  description = "Enable VM Insights"
  type        = bool
  default     = false
}

variable "application_type" {
  description = "Application type"
  type        = string
  default     = "web"
}

variable "appinsights_retention_days" {
  description = "Application Insights retention days"
  type        = number
  default     = 90
}

variable "disable_ip_masking" {
  description = "Disable IP masking"
  type        = bool
  default     = false
}

variable "appinsights_daily_cap_gb" {
  description = "Application Insights daily cap"
  type        = number
  default     = 100
}

variable "disable_daily_cap_notifications" {
  description = "Disable daily cap notifications"
  type        = bool
  default     = false
}

variable "sampling_percentage" {
  description = "Sampling percentage"
  type        = number
  default     = 100
}

variable "appinsights_tags" {
  description = "Application Insights tags"
  type        = map(string)
  default     = {}
}

variable "create_storage_account" {
  description = "Create storage account"
  type        = bool
  default     = true
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication" {
  description = "Storage replication"
  type        = string
  default     = "LRS"
}

variable "blob_retention_days" {
  description = "Blob retention days"
  type        = number
  default     = 7
}

variable "enable_blob_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = false
}

variable "create_action_group" {
  description = "Create action group"
  type        = bool
  default     = true
}

variable "alert_email_receivers" {
  description = "Email receivers"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "alert_sms_receivers" {
  description = "SMS receivers"
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = []
}

variable "alert_webhook_receivers" {
  description = "Webhook receivers"
  type = list(object({
    name        = string
    service_uri = string
  }))
  default = []
}

variable "alert_function_receivers" {
  description = "Function receivers"
  type = list(object({
    name                     = string
    function_app_resource_id = string
    function_name            = string
    http_trigger_url         = string
  }))
  default = []
}

variable "create_default_alerts" {
  description = "Create default alerts"
  type        = bool
  default     = true
}

variable "enable_subscription_diagnostics" {
  description = "Enable subscription diagnostics"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}