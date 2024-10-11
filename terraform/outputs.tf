output "resource_group_name" {
  value = azurerm_resource_group.example.name
}

output "storage_account_name" {
  value = azurerm_storage_account.example.name
}

output "function_app_name" {
  value = azurerm_linux_function_app.example.name
}

output "prefix" {
  value = random_pet.prefix
}