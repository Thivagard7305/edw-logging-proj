########################################
# Azure Logging Module - Outputs
# File: modules/azure-logging/outputs.tf
# Version: 1.0.0
########################################

########################################
# RESOURCE GROUP OUTPUTS
########################################

output "resource_group_name" {
  description = "Name of the resource group containing logging resources"
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group containing logging resources"
  value       = var.create_resource_group ? azurerm_resource_group.logging[0].id : data.azurerm_resource_group.logging[0].id
}

output "location" {
  description = "Azure region where logging resources are deployed"
  value       = local.location
}

########################################
# LOG ANALYTICS WORKSPACE OUTPUTS
########################################

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_workspace_id" {
  description = "Workspace (customer) ID for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.workspace_id
}

output "log_analytics_workspace_primary_key" {
  description = "Primary shared key for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_secondary_key" {
  description = "Secondary shared key for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.secondary_shared_key
  sensitive   = true
}

########################################
# APPLICATION INSIGHTS OUTPUTS
########################################

output "application_insights_id" {
  description = "Resource ID of Application Insights"
  value       = azurerm_application_insights.main.id
}

output "application_insights_name" {
  description = "Name of Application Insights"
  value       = azurerm_application_insights.main.name
}

output "application_insights_app_id" {
  description = "Application ID of Application Insights"
  value       = azurerm_application_insights.main.app_id
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights (legacy, use connection string instead)"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

########################################
# STORAGE ACCOUNT OUTPUTS
########################################

output "storage_account_id" {
  description = "Resource ID of the storage account for log archival"
  value       = var.create_storage_account ? azurerm_storage_account.logs[0].id : null
}

output "storage_account_name" {
  description = "Name of the storage account for log archival"
  value       = var.create_storage_account ? azurerm_storage_account.logs[0].name : null
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = var.create_storage_account ? azurerm_storage_account.logs[0].primary_blob_endpoint : null
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = var.create_storage_account ? azurerm_storage_account.logs[0].primary_access_key : null
  sensitive   = true
}

output "diagnostic_logs_container_name" {
  description = "Name of the container for diagnostic logs"
  value       = var.create_storage_account ? azurerm_storage_container.diagnostic_logs[0].name : null
}

output "archived_logs_container_name" {
  description = "Name of the container for archived logs"
  value       = var.create_storage_account ? azurerm_storage_container.archived_logs[0].name : null
}

########################################
# ACTION GROUP OUTPUTS
########################################

output "action_group_id" {
  description = "Resource ID of the action group"
  value       = var.create_action_group ? azurerm_monitor_action_group.main[0].id : null
}

output "action_group_name" {
  description = "Name of the action group"
  value       = var.create_action_group ? azurerm_monitor_action_group.main[0].name : null
}

########################################
# DIAGNOSTIC SETTINGS OUTPUTS
########################################

output "subscription_diagnostic_setting_id" {
  description = "Resource ID of the subscription diagnostic setting"
  value       = var.enable_subscription_diagnostics ? azurerm_monitor_diagnostic_setting.subscription[0].id : null
}

########################################
# SOLUTIONS OUTPUTS
########################################

output "container_insights_enabled" {
  description = "Whether Container Insights solution is enabled"
  value       = var.enable_container_insights
}

output "security_center_enabled" {
  description = "Whether Security Center solution is enabled"
  value       = var.enable_security_center
}

output "azure_activity_enabled" {
  description = "Whether Azure Activity solution is enabled"
  value       = var.enable_azure_activity
}

output "vm_insights_enabled" {
  description = "Whether VM Insights solution is enabled"
  value       = var.enable_vm_insights
}

########################################
# COMPOSITE OUTPUTS FOR EASY INTEGRATION
########################################

output "log_analytics_connection" {
  description = "Log Analytics connection details for agent configuration"
  value = {
    workspace_id  = azurerm_log_analytics_workspace.main.workspace_id
    workspace_key = azurerm_log_analytics_workspace.main.primary_shared_key
  }
  sensitive = true
}

output "application_insights_config" {
  description = "Application Insights configuration for application integration"
  value = {
    instrumentation_key = azurerm_application_insights.main.instrumentation_key
    connection_string   = azurerm_application_insights.main.connection_string
    app_id             = azurerm_application_insights.main.app_id
  }
  sensitive = true
}

output "all_resource_ids" {
  description = "Map of all resource IDs created by this module"
  value = {
    resource_group          = var.create_resource_group ? azurerm_resource_group.logging[0].id : data.azurerm_resource_group.logging[0].id
    log_analytics_workspace = azurerm_log_analytics_workspace.main.id
    application_insights    = azurerm_application_insights.main.id
    storage_account         = var.create_storage_account ? azurerm_storage_account.logs[0].id : null
    action_group           = var.create_action_group ? azurerm_monitor_action_group.main[0].id : null
  }
}

########################################
# HELPER OUTPUTS
########################################

output "module_info" {
  description = "Information about the deployed module"
  value = {
    module_version = "1.0.0"
    environment    = var.environment
    project_name   = var.project_name
    location       = local.location
  }
}