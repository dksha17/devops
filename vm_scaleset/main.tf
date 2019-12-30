resource "azurerm_resource_group" "test" {
  name = "${var.resource_group_name}"
  location = "${var.location}"
   lifecycle {
   prevent_destroy = true
   }
}

#data "azurerm_virtual_network" "test" {
 # name                = "${var.vnet}"
 # location            = "${azurerm_resource_group.test.location}"
 # resource_group_name = "${azurerm_resource_group.test.name}"
#}

#data "azurerm_subnet" "test" {
 # name                 = "${var.subnet}"
 # resource_group_name  = "${azurerm_resource_group.test.name}"
 # virtual_network_name = "${data.azurerm_virtual_network.test.name}"

#}

# resource "azurerm_public_ip" "test" {
#   name                = "test"
#   location            = "${azurerm_resource_group.test.location}"
#   resource_group_name = "${azurerm_resource_group.test.name}"
#   allocation_method   = "Static"
#   domain_name_label   = "${azurerm_resource_group.test.name}"

 
# }

resource "azurerm_lb" "test" {
  name                = "${var.lb_name}"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
    
    frontend_ip_configuration {
    name                          = "frontend"
    subnet_id                     = "${var.subnet}"
    private_ip_address_allocation = "Dynamic"
    
}
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id     = "${azurerm_lb.test.id}"
  name                = "${var.backend_pool_name}"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
   resource_group_name            = "${azurerm_resource_group.test.name}"
   name                           = "ssh"
   loadbalancer_id                = "${azurerm_lb.test.id}"
   protocol                       = "Tcp"
   frontend_port_start            = 50000
   frontend_port_end              = 50119
   backend_port                   = 22
   frontend_ip_configuration_name = "frontend"
 }

resource "azurerm_lb_probe" "test" {
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id     = "${azurerm_lb.test.id}"
  name                = "xapi-probe"
  protocol            = "Tcp"
  port                = 9080
}
resource "azurerm_lb_rule" "test" {
   resource_group_name            = "${azurerm_resource_group.test.name}"
   loadbalancer_id                = "${azurerm_lb.test.id}"
   probe_id                       = "${azurerm_lb_probe.test.id}"
   backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool.id}"
   frontend_ip_configuration_name = "frontend"
   name                           = "LB-Xapi-Rule"
   protocol                       = "Tcp"
   frontend_port                  = 80
   backend_port                   = 9080
 }

resource "azurerm_virtual_machine_scale_set" "test" {
  name                = "${var.scaleset_name}"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  # automatic rolling upgrade

  upgrade_policy_mode  = "Manual"



  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    # publisher = "Canonical"
    # offer     = "UbuntuServer"
    # sku       = "16.04-LTS"
    # version   = "latest"
    #id = "/subscriptions/a51d82c7-080c-4ccd-867c-c4af37dea0ed/resourceGroups/platform_esgh_sandbox_nonprod_rg/providers/Microsoft.Compute/images/vm-xapi-image-20191022163308"
      id = "/subscriptions/a51d82c7-080c-4ccd-867c-c4af37dea0ed/resourceGroups/platform_esgh_sandbox_nonprod_rg/providers/Microsoft.Compute/images/xapi-vmss-image-20191106101321"
    }

  storage_profile_os_disk {
  #  name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  #storage_profile_data_disk {
   #name = "ui-scaleset-data-managed-disk"
   #managed_disk_type = "Premium_LRS"
   #caching           = "ReadWrite" 
   #create_option     = "Empty"
   #lun               = 0
   #disk_size_gb      = "120"
  #}

  os_profile {
    computer_name_prefix = "ui-scaleset"
    admin_username       = "myadmin"
    admin_password       = "Passwword1234"
  }

  os_profile_linux_config {
    disable_password_authentication = false

   
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = "${var.subnet}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
      #load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lbnatpool.*.id, count.index)}"]
    }
  }

 
}
resource "azurerm_monitor_autoscale_setting" "test" {
  name                = "${var.autoscaling_name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  target_resource_id  = "${azurerm_virtual_machine_scale_set.test.id}"

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.test.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.test.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}
