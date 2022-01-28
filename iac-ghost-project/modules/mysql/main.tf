resource "azurerm_mysql_server" "db-ghost" {
  name                = "${var.ghost_project_vars.app_name}-mysqlserver"
  location            = var.db_resource_group.location
  resource_group_name = var.db_resource_group.name

  administrator_login          = var.ghost_project_vars.ssh_user
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = false // willl be true
  backup_retention_days             = 7     // will be more depending on requirement
  geo_redundant_backup_enabled      = false // will be true
  infrastructure_encryption_enabled = false // will be true
  public_network_access_enabled     = true   
  ssl_enforcement_enabled           = false // will be true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}