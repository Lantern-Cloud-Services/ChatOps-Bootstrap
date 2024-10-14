terraform {
  required_version = ">= 1.5.7"
  backend "azurerm" {
    resource_group_name = "demo-lcs2-dev-chatops-rg1"
    storage_account_name = "demochatopsbackendsa1"
    container_name = "demo-chatops-terraform-state"
    #key = "" dynamically passed in
  }
}
 
provider "azurerm" {
  features {}
}



/*
# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
}
*/

# create resouce group
resource "azurerm_resource_group" "example" {
    name = "${var.project}-${var.environment}-rg-${var.randomname}"
    location = var.location
}
/*
# create function app
resource "azurerm_linux_function_app" "example" {
  name                        = "example-function-app-${var.randomname}"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  service_plan_id             = azurerm_service_plan.example.id
  storage_account_name        = azurerm_storage_account.example.name
  storage_account_access_key  = azurerm_storage_account.example.primary_access_key
  https_only                  = true
  builtin_logging_enabled     = false
  functions_extension_version = "~4"

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }
}
*/
# create app service plan
resource "azurerm_service_plan" "example" {
  name                = "chatopsfunsa${var.randomname}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "B1"
  os_type             = "Linux"
}

# zip up the function app
data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = "../"
  output_path = "function-app.zip"
}

# create storage account for function app
resource "azurerm_storage_account" "example" {
	name                     = "chatopsfunsa${var.randomname}"
	resource_group_name      = azurerm_resource_group.example.name
	location                 = azurerm_resource_group.example.location
	account_tier             = "Standard"
	account_replication_type = "LRS"
}

# create storage container for function app
resource "azurerm_storage_container" "example" {
	name                  = "functionapp"
	storage_account_name  = azurerm_storage_account.example.name
	container_access_type = "private"
}

# create storage blob for function app
resource "azurerm_storage_blob" "storage_blob" {
  name = "function-app.zip"
  storage_account_name = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type = "Block"
  source = "function-app.zip"
}

# create storage blob container sas for function app
data "azurerm_storage_account_blob_container_sas" "storage_account_blob_container_sas" {
  connection_string = azurerm_storage_account.example.primary_connection_string
  container_name    = azurerm_storage_container.example.name

  start = "2021-01-01T00:00:00Z"
  expiry = "2026-01-01T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}

/*
# create function app
resource "azurerm_linux_function_app" "example" {
  name                        = "example-function-app-${var.randomname}"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  service_plan_id             = azurerm_service_plan.example.id
  storage_account_name        = azurerm_storage_account.example.name
  storage_account_access_key  = azurerm_storage_account.example.primary_access_key
  https_only                  = true
  builtin_logging_enabled     = false
  functions_extension_version = "~4"

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }
}
*/

/*
# deploy function to function app
resource "azurerm_linux_function_app" "example" {
  #name                       = "${var.project}-function-app"
  name                       = "example-function-app-${var.randomname}"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = var.location
  service_plan_id        = azurerm_service_plan.example.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"    = "https://${azurerm_storage_account.example.name}.blob.core.windows.net/${azurerm_storage_container.example.name}/${azurerm_storage_blob.storage_blob.name}${data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas}",
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet",
    "AzureWebJobsDisableHomepage" = "true",
  }
  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }  
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  functions_extension_version = "~4"
}
*/