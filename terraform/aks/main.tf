provider "azurerm" {
    version = "1.36.0"
    
    subscription_id = "*****"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "*******"
}

#terraform {
#    backend "azurerm" {
#       storage_account_name  = "*****"
#       container_name        = "***"
#       key                   = "****"
#    }
#}
