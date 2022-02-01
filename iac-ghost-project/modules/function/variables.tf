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

variable function_resource_group {
    type = object({
    name     =  string
    location =  string
  })
}

variable function_virtual_network {
    type = object({
    name     =  string
    location =  string
    address_space = list(string)
  })
}
