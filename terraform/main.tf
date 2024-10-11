terraform {
  required_version = ">= 1.5.7"
  backend "azurerm" {
    resource_group_name = "demo-lcs2-dev-chatops-rg1"
    storage_account_name = "demochatopsbackendsa1"
    container_name = "demo-chatops-terraform-state"
    key = "chopsdemo-dev-state.tfstate"
    #key = "${var.project}-${var.environment}-state.tfstate"
  }
}
 
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
    name = "${var.project}-${var.environment}-rg"
    location = var.location
}
