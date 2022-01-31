///NOTE: in production azurerm_mysql_flexible_server to be used instead
resource "azurerm_mysql_server" "ghost-db-server" {
  name                = "${var.ghost_project_vars.app_name}-mysqlserver"
  location            = var.db_resource_group.location
  resource_group_name = var.db_resource_group.name

  administrator_login          = var.db_user
  administrator_login_password = var.db_password

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = false // willl be true
  backup_retention_days             = 7     // will be more depending on requirement
  geo_redundant_backup_enabled      = false // will be true
  infrastructure_encryption_enabled = false // will be true
  public_network_access_enabled     = true   
  ssl_enforcement_enabled           = true 
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_firewall_rule" "ghost-db-server-firewall" {
  name                = "${azurerm_mysql_server.ghost-db-server.name}-firewall"
  resource_group_name = var.db_resource_group.name
  server_name         = azurerm_mysql_server.ghost-db-server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_database" "db-ghost" {
  name                = "db-ghost-test"
  resource_group_name = var.db_resource_group.name
  server_name         = azurerm_mysql_server.ghost-db-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}