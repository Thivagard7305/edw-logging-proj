terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.96"
    }
  }

  # Backend is partial here. We fill in the details via backend.hcl or CLI
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}