terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.96"
    }
  }
}

########################################
# Data Sources
########################################

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Get existing resource group if not creating new one
data "azurerm_resource_group" "logging" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

########################################
# Local Variables
########################################

locals {
  # Resource group reference
  resource_group_name = var.create_resource_group ? azurerm_resource_group.logging[0].name : data.azurerm_resource_group.logging[0].name
  location            = var.create_resource_group ? azurerm_resource_group.logging[0].location : data.azurerm_resource_group.logging[0].location
  
  # Resource naming convention
  log_analytics_name   = "${var.project_name}-law-${var.environment}"
  app_insights_name    = "${var.project_name}-appi-${var.environment}"
  storage_account_name = lower(replace("${var.project_name}logs${var.environment}", "-", ""))
  action_group_name    = "${var.project_name}-ag-${var.environment}"
  
  # Tags to apply to all resources
  module_tags = merge(
    var.common_tags,
    {
      "Module"      = "azure-logging"
      "Environment" = var.environment
      "ManagedBy"   = "Terraform"
    }
  )
}

########################################
# Resource Group
########################################

resource "azurerm_resource_group" "logging" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  
  tags = merge(
    local.module_tags,
    var.resource_group_tags,
    {
      "Purpose" = "Logging Infrastructure"
    }
  )
}

########################################
# Log Analytics Workspace
########################################

resource "azurerm_log_analytics_workspace" "main" {
  name                = local.log_analytics_name
  location            = local.location
  resource_group_name = local.resource_group_name
  
  # Pricing tier
  sku = var.log_analytics_sku
  
  # Data retention
  retention_in_days = var.log_retention_days
  
  # Daily quota for cost control
  daily_quota_gb = var.daily_quota_gb
  
  # Network settings
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled
  
  tags = merge(
    local.module_tags,
    var.log_analytics_tags,
    {
      "Resource" = "Log Analytics Workspace"
    }
  )
  
  lifecycle {
    ignore_changes = [
      # Prevent recreation on minor changes
      tags["CreatedDate"]
    ]
  }
}

########################################
# Log Analytics Solutions
########################################

# Container Insights Solution
resource "azurerm_log_analytics_solution" "container_insights" {
  count                 = var.enable_container_insights ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = local.location
  resource_group_name   = local.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = local.module_tags
}

# Security Center Solution
resource "azurerm_log_analytics_solution" "security_center" {
  count                 = var.enable_security_center ? 1 : 0
  solution_name         = "Security"
  location              = local.location
  resource_group_name   = local.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }

  tags = local.module_tags
}

# Azure Activity Solution
resource "azurerm_log_analytics_solution" "azure_activity" {
  count                 = var.enable_azure_activity ? 1 : 0
  solution_name         = "AzureActivity"
  location              = local.location
  resource_group_name   = local.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureActivity"
  }

  tags = local.module_tags
}

# VM Insights Solution
resource "azurerm_log_analytics_solution" "vm_insights" {
  count                 = var.enable_vm_insights ? 1 : 0
  solution_name         = "VMInsights"
  location              = local.location
  resource_group_name   = local.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }

  tags = local.module_tags
}

########################################
# Application Insights
########################################

resource "azurerm_application_insights" "main" {
  name                = local.app_insights_name
  location            = local.location
  resource_group_name = local.resource_group_name
  
  # Link to Log Analytics Workspace
  workspace_id = azurerm_log_analytics_workspace.main.id
  
  # Application type
  application_type = var.application_type
  
  # Data retention
  retention_in_days = var.appinsights_retention_days
  
  # IP masking
  disable_ip_masking = var.disable_ip_masking
  
  # Daily cap
  daily_data_cap_in_gb                  = var.appinsights_daily_cap_gb
  daily_data_cap_notifications_disabled = var.disable_daily_cap_notifications
  
  # Sampling
  sampling_percentage = var.sampling_percentage
  
  tags = merge(
    local.module_tags,
    var.appinsights_tags,
    {
      "Resource" = "Application Insights"
    }
  )
}

########################################
# Storage Account for Logs Archive
########################################

resource "azurerm_storage_account" "logs" {
  count                    = var.create_storage_account ? 1 : 0
  name                     = local.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
  
  # Security settings
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  shared_access_key_enabled       = true
  
  # Advanced threat protection
  # Note: This requires a separate azurerm_advanced_threat_protection resource
  
  # Blob properties
  blob_properties {
    # Soft delete for blobs
    delete_retention_policy {
      days = var.blob_retention_days
    }
    
    # Soft delete for containers
    container_delete_retention_policy {
      days = var.blob_retention_days
    }
    
    # Versioning
    versioning_enabled = var.enable_blob_versioning
  }

  lifecycle {
    ignore_changes = [
      static_website
    ]
  }
  
  tags = merge(
    local.module_tags,
    {
      "Resource" = "Logs Storage Account"
    }
  )
}

# Storage container for diagnostic logs
resource "azurerm_storage_container" "diagnostic_logs" {
  count                 = var.create_storage_account ? 1 : 0
  name                  = "diagnostic-logs"
  storage_account_name    = azurerm_storage_account.logs[0].name
  container_access_type = "private"
}

# Storage container for archived logs
resource "azurerm_storage_container" "archived_logs" {
  count                 = var.create_storage_account ? 1 : 0
  name                  = "archived-logs"
  storage_account_name    = azurerm_storage_account.logs[0].name
  container_access_type = "private"
}

########################################
# Action Group for Alerts
########################################

resource "azurerm_monitor_action_group" "main" {
  count               = var.create_action_group ? 1 : 0
  name                = local.action_group_name
  resource_group_name = local.resource_group_name
  short_name          = substr(replace("${var.project_name}-${var.environment}", "-", ""), 0, 12)
  
  enabled = true
  
  # Email notifications
  dynamic "email_receiver" {
    for_each = var.alert_email_receivers
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = true
    }
  }
  
  # SMS notifications
  dynamic "sms_receiver" {
    for_each = var.alert_sms_receivers
    content {
      name         = sms_receiver.value.name
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }
  
  # Webhook notifications
  dynamic "webhook_receiver" {
    for_each = var.alert_webhook_receivers
    content {
      name                    = webhook_receiver.value.name
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = true
    }
  }
  
  # Azure Function webhooks
  dynamic "azure_function_receiver" {
    for_each = var.alert_function_receivers
    content {
      name                     = azure_function_receiver.value.name
      function_app_resource_id = azure_function_receiver.value.function_app_resource_id
      function_name            = azure_function_receiver.value.function_name
      http_trigger_url         = azure_function_receiver.value.http_trigger_url
      use_common_alert_schema  = true
    }
  }
  
  tags = local.module_tags
}

########################################
# Subscription-Level Diagnostic Settings
########################################

resource "azurerm_monitor_diagnostic_setting" "subscription" {
  count                      = var.enable_subscription_diagnostics ? 1 : 0
  name                       = "subscription-diagnostics-${var.environment}"
  target_resource_id         = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  storage_account_id         = var.create_storage_account ? azurerm_storage_account.logs[0].id : null
  
  # Enable all available log categories
  enabled_log {
    category = "Administrative"
  }
  
  enabled_log {
    category = "Security"
  }
  
  enabled_log {
    category = "ServiceHealth"
  }
  
  enabled_log {
    category = "Alert"
  }
  
  enabled_log {
    category = "Recommendation"
  }
  
  enabled_log {
    category = "Policy"
  }
  
  enabled_log {
    category = "Autoscale"
  }
  
  enabled_log {
    category = "ResourceHealth"
  }
}

# Alert for Log Analytics workspace quota
resource "azurerm_monitor_metric_alert" "law_quota" {
  count               = var.create_action_group && var.create_default_alerts && var.daily_quota_gb > 0 ? 1 : 0
  name                = "${local.log_analytics_name}-quota-alert"
  resource_group_name = local.resource_group_name
  scopes              = [azurerm_log_analytics_workspace.main.id]
  description         = "Alert when Log Analytics workspace quota is near limit"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT1H"
  
  criteria {
    metric_namespace = "Microsoft.OperationalInsights/workspaces"
    metric_name      = "Usage"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.daily_quota_gb * 1024 * 0.8  # 80% of quota in MB
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.main[0].id
  }
  
  tags = local.module_tags
}