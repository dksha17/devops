# Configure the Azure Provider
provider "azurerm" {
  version = "=1.33.1"
}

# Configure the Azure backend (blob storage)
#terraform {
#  backend "azurerm" {
    #resource_group_name = ""
#    storage_account_name = ""
#    container_name       = ""
#    key                  = ""
#    access_key           = ""
#  }
#}
