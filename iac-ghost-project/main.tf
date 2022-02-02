
resource "azurerm_resource_group" "rg-ghost" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vn-ghost" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.rg-ghost.name
  location            = azurerm_resource_group.rg-ghost.location
  address_space       = ["10.0.0.0/16"]

  depends_on = [azurerm_resource_group.rg-ghost]
}

module "keyvault" {
  source = "./modules/keyvault"

  # (Azure-specific configuration arguments)
  kv_resource_group = azurerm_resource_group.rg-ghost
  kv_virtual_network = azurerm_virtual_network.vn-ghost
  ghost_project_vars = {
      app_name     =  var.app_name
      subscription_id =  var.subscription_id
      client_id = var.client_id
      client_secret = var.client_secret
      tenant_id = var.tenant_id
      ssh_user = var.ssh_user
      ssh_public_key = var.ssh_public_key
      location = var.location      
    }

  depends_on = [azurerm_virtual_network.vn-ghost]
}

module "mysql_db" {
  source = "./modules/mysql"

  # (Azure-specific configuration arguments)
  db_resource_group = azurerm_resource_group.rg-ghost
  db_virtual_network = azurerm_virtual_network.vn-ghost
  db_user = module.keyvault.db_user
  db_password = module.keyvault.db_password
  ghost_project_vars = {
      app_name     =  var.app_name
      subscription_id =  var.subscription_id
      client_id = var.client_id
      client_secret = var.client_secret
      tenant_id = var.tenant_id
      ssh_user = var.ssh_user
      ssh_public_key = var.ssh_public_key
      location = var.location      
    }
  depends_on = [module.keyvault]
}

module "k8s_cluster" {
  source = "./modules/k8s"

  # (Azure-specific configuration arguments)
  k8s_resource_group = azurerm_resource_group.rg-ghost
  k8s_virtual_network = azurerm_virtual_network.vn-ghost
  agent_min_count = var.agent_min_count
  agent_max_count = var.agent_max_count
  max_pods = var.max_pods
  ghost_project_vars = {
      app_name     =  var.app_name
      subscription_id =  var.subscription_id
      client_id = var.client_id
      client_secret = var.client_secret
      tenant_id = var.tenant_id
      ssh_user = var.ssh_user
      ssh_public_key = var.ssh_public_key
      location = var.location      
    }

  depends_on = [module.mysql_db]
}

# module "function-app" {
#   source = "./modules/function"

#   # (Azure-specific configuration arguments)
#   function_resource_group = azurerm_resource_group.rg-ghost
#   function_virtual_network = azurerm_virtual_network.vn-ghost
#   ghost_project_vars = {
#       app_name     =  var.app_name
#       subscription_id =  var.subscription_id
#       client_id = var.client_id
#       client_secret = var.client_secret
#       tenant_id = var.tenant_id
#       ssh_user = var.ssh_user
#       ssh_public_key = var.ssh_public_key
#       location = var.location      
#     }

#   depends_on = [module.k8s_cluster]
# }

