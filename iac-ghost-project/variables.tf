variable "app_name" {
  default = "nordcloud_assesment"
  description   = "Location of the resource group."
}

variable "subscription_id" {
  default = ""
}

variable "client_id" {
  default = ""
}

variable "client_secret" {
  default = ""
}

variable "tenant_id" {
  default = "bad3cd3d-a88a-478d-a251-43f7355aad77"
}

variable resource_group_name {
    default = "rg-nordcloud-ghost"
}

variable virtual_network_name {
    default = "vn-nordcloud-ghost"
}

variable "location" {
  default = "eastus"
  description   = "Location of the resource group."
}

variable "ssh_user" {
  default = "bishnuk"
}

variable "ssh_public_key" {
    default = ".ssh/id_rsa.pub"
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
