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
    name = "${var.project}-${var.environment}-rg-${var.deployment_name}"
    location = var.location
}

# create app service plan
resource "azurerm_service_plan" "example" {
  name                = "chatopsfunsp${var.deployment_name}"
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
	name                     = "cfsa${var.deployment_name}"
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

# Create Cosmos DB account
resource "azurerm_cosmosdb_account" "orders_db" {
  name                = "orders-cosmos-${var.deployment_name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.example.location
    failover_priority = 0
  }
}

# Create Cosmos DB SQL Database
resource "azurerm_cosmosdb_sql_database" "orders_database" {
  name                = "OrdersDatabase"
  resource_group_name = azurerm_cosmosdb_account.orders_db.resource_group_name
  account_name        = azurerm_cosmosdb_account.orders_db.name
}

# Create Cosmos DB SQL Container
resource "azurerm_cosmosdb_sql_container" "orders_container" {
  name                = "OrdersContainer"
  resource_group_name = azurerm_cosmosdb_account.orders_db.resource_group_name
  account_name        = azurerm_cosmosdb_account.orders_db.name
  database_name       = azurerm_cosmosdb_sql_database.orders_database.name
  partition_key_path  = "/orderID"
  throughput          = 400
}

# create function app
resource "azurerm_linux_function_app" "example" {
  name                        = "orderprocessor-${var.deployment_name}"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  service_plan_id             = azurerm_service_plan.example.id
  storage_account_name        = azurerm_storage_account.example.name
  storage_account_access_key  = azurerm_storage_account.example.primary_access_key
  https_only                  = true
  builtin_logging_enabled     = true
  functions_extension_version = "~4"

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"    = "https://${azurerm_storage_account.example.name}.blob.core.windows.net/${azurerm_storage_container.example.name}/${azurerm_storage_blob.storage_blob.name}${data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas}",
    "FUNCTIONS_WORKER_RUNTIME"    = "dotnet",
    "AzureWebJobsDisableHomepage" = "true",
    "CosmosDBConnection"          = azurerm_cosmosdb_account.orders_db.primary_sql_connection_string,
  }

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }
}