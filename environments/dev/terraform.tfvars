# Basic Settings
environment         = "dev"
project_name        = "edwproj"              # CHANGE THIS
location            = "eastus"
resource_group_name = "rg-edwproj-logging"

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
  ManagedBy   = "Thivagar"        # CHANGE THIS
  CostCenter  = "DevOps"        # CHANGE THIS
  Project     = "edw-proj"          # CHANGE THIS
}