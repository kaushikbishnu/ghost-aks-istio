data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv-ghost" {
  name                        = "${var.ghost_project_vars.app_name}-kv"
  location                    = var.kv_resource_group.location
  resource_group_name         = var.kv_resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.ghost_project_vars.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
      "purge",
      "recover"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "db_user" {
  name         = "db-user"
  value        = var.ghost_project_vars.ssh_user
  key_vault_id = azurerm_key_vault.kv-ghost.id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.kv-ghost.id
}

resource "azurerm_key_vault_secret" "sp_password" {
  name         = "sp-password"
  value        = var.ghost_project_vars.client_secret
  key_vault_id = azurerm_key_vault.kv-ghost.id
}