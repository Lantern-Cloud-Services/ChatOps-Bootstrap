terraform {
  required_version = ">= 1.5.7"
  backend "azurerm" {
    resource_group_name = "demo-lcs2-dev-chatops-rg1"
    storage_account_name = "demochatopsbackendsa1"
    container_name = "demo-chatops-terraform-state"
    key = "chatopsdemo-dev-state.tfstate"
    #key = "${var.project}-${var.environment}-state.tfstate"
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


resource "azurerm_resource_group" "example" {
    name = "${var.project}-${var.environment}-rg-${var.randomname}"
    location = var.location
}

/*
resource "azurerm_function_app" "example" {
	name                       = "example-function-app-${var.randomname}"
	location                   = azurerm_resource_group.example.location
	resource_group_name        = azurerm_resource_group.example.name
	app_service_plan_id        = azurerm_app_service_plan.example.id
	storage_account_name       = azurerm_storage_account.example.name
	storage_account_access_key = azurerm_storage_account.example.primary_access_key
	os_type                    = "linux"
	version                    = "~6"
	identity {
		type = "SystemAssigned"
	}
}
*/

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

resource "azurerm_service_plan" "example" {
  name                = "chatopsfunsa${var.randomname}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "B1"
  os_type             = "Linux"
}

data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = "../"
  output_path = "function-app.zip"
}

resource "azurerm_storage_account" "example" {
	name                     = "chatopsfunsa${var.randomname}"
	resource_group_name      = azurerm_resource_group.example.name
	location                 = azurerm_resource_group.example.location
	account_tier             = "Standard"
	account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
	name                  = "functionapp"
	storage_account_name  = azurerm_storage_account.example.name
	container_access_type = "private"
}

resource "azurerm_storage_blob" "storage_blob" {
  name = "${filesha256(data.archive_file.output_path)}.zip"
  storage_account_name = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type = "Block"
  source = data.archive_file.output_path
}


resource "azurerm_storage_blob" "function_zip" {
	name                   = "functionapp.zip"
	storage_account_name   = azurerm_storage_account.example.name
	storage_container_name = azurerm_storage_container.example.name
	type                   = "Block"
	source                 = "path/to/your/functionapp.zip"
}


/*
resource "azurerm_function_app_function" "example" {
	name            = "example-function"
	function_app_id = azurerm_function_app.example.id
	file_path       = azurerm_storage_blob.function_zip.name
	content_type    = "application/zip"
}
*/
