resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "test" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = var.log_analytics_workspace_location
    resource_group_name = var.k8s_resource_group.name
    sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.test.location
    resource_group_name   = var.k8s_resource_group.name
    workspace_resource_id = azurerm_log_analytics_workspace.test.id
    workspace_name        = azurerm_log_analytics_workspace.test.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "${var.ghost_project_vars.app_name}-k8s-cluster"
    location            = var.k8s_resource_group.location
    resource_group_name = var.k8s_resource_group.name
    dns_prefix          = var.dns_prefix

    linux_profile {
        admin_username = var.ghost_project_vars.ssh_user

        ssh_key {
            key_data = file(var.ghost_project_vars.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = "Standard_B2s"
        enable_auto_scaling = true
        min_count = var.agent_min_count
        max_count = var.agent_max_count
        max_pods = var.max_pods        
    }
    

    service_principal {
        client_id     = var.ghost_project_vars.client_id
        client_secret = var.ghost_project_vars.client_secret
    }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
        }
    }

    network_profile {
        load_balancer_sku = "Standard"
        network_plugin = "kubenet"
    }

    tags = {
        Environment = "Development"
    }
}