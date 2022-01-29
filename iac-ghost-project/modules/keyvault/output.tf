output "db_user" {
  value = azurerm_key_vault_secret.db_user.value
}

output "db_password" {
  value = azurerm_key_vault_secret.db_password.value
}