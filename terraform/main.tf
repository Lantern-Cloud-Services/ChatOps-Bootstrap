terraform {
  required_version = ">= 1.5.7"
  backend "azurerm" {
    resource_group_name  = "demo-lcs2-dev-chatops-rg1"
    storage_account_name = "demochatopsbackendsa1"
    container_name       = "demo-chatops-terraform-state"
    key                  = "${var.project}-${var.environment}-state.tfstate"
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Root module should specify the maximum provider version
      # The ~> operator is a convenient shorthand for allowing only patch releases within a specific minor release.
      version = "~> 2.26"
    }
  }
}
 
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
    name = "${var.project}-${var.environment}-rg"
    location = var.location
}
