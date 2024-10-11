terraform {
  required_version = ">= 1.5.7"
  backend "azurerm" {
    resource_group_name  = "demo-lcs2-dev-chatops-rg1"
    storage_account_name = "demochatopsbackendsa1"
    container_name       = "demo-chatops-terraform-state"
    key                  = "${var.project}-${var.environment}-state.tfstate"
    #key                  = "demo-chatops-terraform-state.tfstate"
  }
}
 
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
    name = "${var.project}-${var.environment}-rg"
    location = var.location
}




/*
resource "azurerm_function_app" "example" {
    name                       = "example-function-app"
    location                   = azurerm_resource_group.test.location
    resource_group_name        = azurerm_resource_group.test.name
    app_service_plan_id        = azurerm_app_service_plan.example.id
    storage_account_name       = azurerm_storage_account.example.name
    storage_account_access_key = azurerm_storage_account.example.primary_access_key
    os_type                    = "linux"
    runtime_stack              = "dotnet"
    version                    = "~6"

    site_config {
        application_stack {
            dotnet_version = "6.0"
        }
    }

    identity {
        type = "SystemAssigned"
    }
}

resource "azurerm_app_service_plan" "example" {
    name                = "example-app-service-plan"
    location            = azurerm_resource_group.test.location
    resource_group_name = azurerm_resource_group.test.name
    kind                = "FunctionApp"
    reserved            = true

    sku {
        tier = "Dynamic"
        size = "Y1"
    }
}

resource "azurerm_storage_account" "example" {
    name                     = "examplestorageacc"
    resource_group_name      = azurerm_resource_group.test.name
    location                 = azurerm_resource_group.test.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_blob" "function_zip" {
    name                   = "functionapp.zip"
    storage_account_name   = azurerm_storage_account.example.name
    storage_container_name = azurerm_storage_container.example.name
    type                   = "Block"
    source                 = "path/to/your/functionapp.zip"
}

resource "azurerm_storage_container" "example" {
    name                  = "functionapp"
    storage_account_name  = azurerm_storage_account.example.name
    container_access_type = "private"
}

resource "azurerm_function_app_function" "example" {
    name            = "example-function"
    function_app_id = azurerm_function_app.example.id
    file_path       = azurerm_storage_blob.function_zip.name
    content_type    = "application/zip"
}
*/