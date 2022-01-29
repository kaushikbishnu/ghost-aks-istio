variable ghost_project_vars {
    type = object({
    app_name     =  string
    subscription_id =  string
    client_id = string
    client_secret = string
    tenant_id = string
    ssh_user = string
    ssh_public_key = string
    location = string    
  })
}

variable k8s_resource_group {
    type = object({
    name     =  string
    location =  string
  })
}

variable k8s_virtual_network {
    type = object({
    name     =  string
    location =  string
    address_space = list(string)
  })
}

variable "agent_min_count" {
  default = 1
}

variable "agent_max_count" {
  default = 3
}

variable "max_pods" {
  default = 5
}

variable "agent_count" {
    default = 1
}

variable "dns_prefix" {
    default = "k8sghost"
}

variable log_analytics_workspace_name {
    default = "ghostLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}