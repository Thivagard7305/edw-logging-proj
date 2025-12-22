########################################
# REQUIRED VARIABLES
########################################

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name used for resource naming (max 10 chars, alphanumeric only)"
  type        = string
  validation {
    condition     = length(var.project_name) <= 10 && can(regex("^[a-zA-Z0-9]+$", var.project_name))
    error_message = "Project name must be 10 characters or less and contain only alphanumeric characters."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for logging resources"
  type        = string
}

########################################
# RESOURCE GROUP CONFIGURATION
########################################

variable "create_resource_group" {
  description = "Whether to create a new resource group or use an existing one"
  type        = bool
  default     = true
}

variable "resource_group_tags" {
  description = "Additional tags specific to the resource group"
  type        = map(string)
  default     = {}
}

########################################
# LOG ANALYTICS WORKSPACE
########################################

variable "log_analytics_sku" {
  description = "SKU for Log Analytics Workspace (PerGB2018 or CapacityReservation)"
  type        = string
  default     = "PerGB2018"
  validation {
    condition     = contains(["PerGB2018", "CapacityReservation"], var.log_analytics_sku)
    error_message = "SKU must be either PerGB2018 or CapacityReservation."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain logs (30-730, or -1 for unlimited)"
  type        = number
  default     = 30
  validation {
    condition     = var.log_retention_days == -1 || (var.log_retention_days >= 30 && var.log_retention_days <= 730)
    error_message = "Retention must be between 30 and 730 days, or -1 for unlimited."
  }
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB (-1 for unlimited). Useful for cost control"
  type        = number
  default     = -1
}

variable "internet_ingestion_enabled" {
  description = "Enable internet ingestion for Log Analytics Workspace"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Enable internet query for Log Analytics Workspace"
  type        = bool
  default     = true
}

variable "log_analytics_tags" {
  description = "Additional tags specific to Log Analytics Workspace"
  type        = map(string)
  default     = {}
}

########################################
# LOG ANALYTICS SOLUTIONS
########################################

variable "enable_container_insights" {
  description = "Enable Container Insights solution for AKS monitoring"
  type        = bool
  default     = false
}

variable "enable_security_center" {
  description = "Enable Security Center solution"
  type        = bool
  default     = true
}

variable "enable_azure_activity" {
  description = "Enable Azure Activity solution for activity log analysis"
  type        = bool
  default     = true
}

variable "enable_vm_insights" {
  description = "Enable VM Insights solution for virtual machine monitoring"
  type        = bool
  default     = false
}

########################################
# APPLICATION INSIGHTS
########################################

variable "application_type" {
  description = "Type of application being monitored"
  type        = string
  default     = "web"
  validation {
    condition     = contains(["web", "ios", "java", "other", "Node.JS", "store"], var.application_type)
    error_message = "Application type must be one of: web, ios, java, other, Node.JS, store."
  }
}

variable "appinsights_retention_days" {
  description = "Number of days to retain Application Insights data (30-730)"
  type        = number
  default     = 90
  validation {
    condition     = var.appinsights_retention_days >= 30 && var.appinsights_retention_days <= 730
    error_message = "Application Insights retention must be between 30 and 730 days."
  }
}

variable "disable_ip_masking" {
  description = "Disable IP masking in Application Insights telemetry"
  type        = bool
  default     = false
}

variable "appinsights_daily_cap_gb" {
  description = "Daily data volume cap in GB for Application Insights"
  type        = number
  default     = 100
}

variable "disable_daily_cap_notifications" {
  description = "Disable notifications when daily cap is reached"
  type        = bool
  default     = false
}

variable "sampling_percentage" {
  description = "Percentage of telemetry to sample (0-100). 100 means no sampling"
  type        = number
  default     = 100
  validation {
    condition     = var.sampling_percentage >= 0 && var.sampling_percentage <= 100
    error_message = "Sampling percentage must be between 0 and 100."
  }
}

variable "appinsights_tags" {
  description = "Additional tags specific to Application Insights"
  type        = map(string)
  default     = {}
}

########################################
# STORAGE ACCOUNT
########################################

variable "create_storage_account" {
  description = "Create storage account for long-term log archival"
  type        = bool
  default     = true
}

variable "storage_account_tier" {
  description = "Storage account performance tier (Standard or Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage tier must be Standard or Premium."
  }
}

variable "storage_account_replication" {
  description = "Storage account replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication)
    error_message = "Replication must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "storage_container_names" {
  description = "Storage container name"
  type        = string
  default     = "edw-proj-logs-container"
}

variable "blob_retention_days" {
  description = "Number of days to retain deleted blobs (soft delete)"
  type        = number
  default     = 7
  validation {
    condition     = var.blob_retention_days >= 1 && var.blob_retention_days <= 365
    error_message = "Blob retention must be between 1 and 365 days."
  }
}

variable "enable_blob_versioning" {
  description = "Enable blob versioning for the storage account"
  type        = bool
  default     = false
}

########################################
# ACTION GROUP & ALERTS
########################################

variable "create_action_group" {
  description = "Create action group for alert notifications"
  type        = bool
  default     = true
}

variable "alert_email_receivers" {
  description = "List of email receivers for alert notifications"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
  
  validation {
    condition     = alltrue([for r in var.alert_email_receivers : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", r.email_address))])
    error_message = "All email addresses must be valid."
  }
}

variable "alert_sms_receivers" {
  description = "List of SMS receivers for alert notifications"
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = []
}

variable "alert_webhook_receivers" {
  description = "List of webhook receivers for alert notifications"
  type = list(object({
    name        = string
    service_uri = string
  }))
  default = []
  
  validation {
    condition     = alltrue([for r in var.alert_webhook_receivers : can(regex("^https://", r.service_uri))])
    error_message = "All webhook URIs must use HTTPS."
  }
}

variable "alert_function_receivers" {
  description = "List of Azure Function receivers for alert notifications"
  type = list(object({
    name                     = string
    function_app_resource_id = string
    function_name            = string
    http_trigger_url         = string
  }))
  default = []
}

variable "create_default_alerts" {
  description = "Create default metric alerts for quota and capacity"
  type        = bool
  default     = true
}

########################################
# DIAGNOSTIC SETTINGS
########################################

variable "enable_subscription_diagnostics" {
  description = "Enable subscription-level diagnostic settings"
  type        = bool
  default     = true
}

########################################
# COMMON TAGS
########################################

variable "common_tags" {
  description = "Common tags to apply to all resources created by this module"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
  
  validation {
    condition     = contains(keys(var.common_tags), "ManagedBy")
    error_message = "Common tags must include 'ManagedBy' key."
  }
}