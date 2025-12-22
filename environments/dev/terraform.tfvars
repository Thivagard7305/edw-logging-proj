# Basic Settings
environment         = "dev"
project_name        = "edw-proj"              # CHANGE THIS
location            = "eastus"
resource_group_name = "rg-edw-proj-logging-dev"

# Retention & Quotas
log_retention_days = 30
daily_quota_gb     = 5

# Alerting
alert_email_receivers = [
  {
    name          = "DevTeam"
    email_address = "thivagar.123.raja@gmil.com"  # CHANGE THIS
  }
]

# Tags
common_tags = {
  Environment = "Development"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"        # CHANGE THIS
  Project     = "MyApp"
}