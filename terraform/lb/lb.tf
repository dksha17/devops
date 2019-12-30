# Configure the Azure Provider
provider "azurerm" {
 version = "=1.33.1"
}

# Configure the Azure backend (blob storage)
terraform {
  backend "azurerm" {
    #resource_group_name  = "platform_esgh_sandbox_nonprod_rg"
    storage_account_name = "*****"
    container_name       = "****"
    key                  = ""
    access_key            = ""
  }
}

resource "azurerm_resource_group" "sw" {
    name = "platform_esgh_github_lb_test_rg"
    location = "West US"
    lifecycle {
        prevent_destroy = true
    }   
}

resource "azurerm_public_ip" "sw" {
    name = "zduw-esgh-ghe-lb-publicip-02"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.sw.name}"
    sku = "Standard"
    allocation_method = "Static"
}

resource "azurerm_lb" "test-lb" {
    name = "zduw-esgh-ghe-ext-lb-02"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.sw.name}"
    sku = "Standard"
    frontend_ip_configuration {
        name = "LoadBalancerFrontEnd-02"
        public_ip_address_id = "${azurerm_public_ip.sw.id}"
    }  
}

resource "azurerm_lb_backend_address_pool" "sw" {
    resource_group_name = "${azurerm_resource_group.sw.name}"
    loadbalancer_id = "${azurerm_lb.test-lb.id}"
    name = "ghe-bep-02"
}

resource "azurerm_lb_outbound_rule" "sw" {
    resource_group_name = "${azurerm_resource_group.sw.name}"
    loadbalancer_id = "${azurerm_lb.test-lb.id}"
    name = "OutboundRule"
    protocol = "Tcp"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.sw.id}"
    frontend_ip_configuration {
        name = "LoadBalancerFrontEnd-02"
    }
}
