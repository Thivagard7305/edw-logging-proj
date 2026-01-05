########################################
# DEVELOPMENT ENVIRONMENT - Backend Config
# File: environments/dev/backend.hcl
########################################

resource_group_name  = "rg-edwproj-logging-dev"
storage_account_name = "edwprojloggingsadev"
container_name       = "edw-logging-tfstate-cont"
key                  = "terraform.tfstate"