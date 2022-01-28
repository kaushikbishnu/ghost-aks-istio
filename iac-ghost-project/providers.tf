# The following variable is used to configure the provider's authentication
# token. You don't need to provide a token on the command line to apply changes,
# though: using the remote backend, Terraform will execute remotely in Terraform
# Cloud where your token is already securely stored in your workspace!

variable "provider_token" {
  type = string
  sensitive = true
  default = "IJNTGMzNDZjaiw.atlasv1.c5pxOXUTVKhEc2uJ4ZtRsaxpfGltUvitik8Yv4ClDdg6vE9qhPyeHizH57IJy6U0rek"
}

provider "fakewebservices" {
  token = var.provider_token
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id

  features {}
}
