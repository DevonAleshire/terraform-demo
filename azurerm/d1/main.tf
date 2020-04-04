##################
# Variables
##################
variable azure_subscriptionId {}
variable azure_appId {}
variable azure_password  {}
variable azure_tenant  {}

variable "region" {
  type    = string
  default = "West US"
}

##################
# Provider
##################
provider "azurerm"{
    features {}
    subscription_id = var.azure_subscriptionId
    client_id      = var.azure_appId  
    client_secret  = var.azure_password
    tenant_id      = var.azure_tenant
}

##################
# Resources
##################
resource "azurerm_resource_group" "tf-demo"{
    name     = "tf-demo-rg"
    location = var.region
}