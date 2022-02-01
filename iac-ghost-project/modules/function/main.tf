resource "azurerm_storage_account" "ghost-nordcloud" {
  name                     = "ghostnordcloud"
  resource_group_name      = var.function_resource_group.name
  location                 = var.function_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "ghost-nordcloud" {
  name                = "aghost-nordcloud-service-plan"
  location            = var.function_resource_group.location
  resource_group_name = var.function_resource_group.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "example" {
  name                       = "ghost-nordcloud-functions"
  location                   = var.function_resource_group.location
  resource_group_name        = var.function_resource_group.name
  app_service_plan_id        = azurerm_app_service_plan.ghost-nordcloud.id
  storage_account_name       = azurerm_storage_account.ghost-nordcloud.name
  storage_account_access_key = azurerm_storage_account.ghost-nordcloud.primary_access_key
}