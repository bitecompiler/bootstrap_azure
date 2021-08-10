# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.70.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.5.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

provider "azuread" {
  #features {}
}