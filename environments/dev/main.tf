module "logging" {
  # REFERENCING LOCAL PATH
  source = "../../modules/azure-logging"

  # ENVIRONMENT CONTEXT
  project_name        = var.project_name
  environment         = "dev"
  location            = var.location
  resource_group_name = "rg-${var.project_name}-logging-dev"
  
  # DEV SPECIFIC TOGGLES
  create_resource_group     = true
  log_retention_days        = 30   # Save money in Dev
  enable_container_insights = true # We need to debug containers in Dev
  create_action_group       = false # Don't wake me up for Dev alerts
  
  # TAGGING
  common_tags = {
    ManagedBy = "Terraform"
    Owner     = "DevOpsTeam"
    Env       = "Development"
  }
}

# Re-export necessary outputs so we can see them after 'terraform apply'
output "log_analytics_workspace_id" {
  value = module.logging.log_analytics_workspace_id
}