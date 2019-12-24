resource "azurerm_resource_group" "k8s" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"
}

resource "azurerm_log_analytics_workspace" "test" {
    name                = "${var.log_analytics_workspace_name}"
    location            = "${var.log_analytics_workspace_location}"
    resource_group_name = "${azurerm_resource_group.k8s.name}"
    sku                 = "${var.log_analytics_workspace_sku}"
}

resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = "${azurerm_log_analytics_workspace.test.location}"
    resource_group_name   = "${azurerm_resource_group.k8s.name}"
    workspace_resource_id = "${azurerm_log_analytics_workspace.test.id}"
    workspace_name        = "${azurerm_log_analytics_workspace.test.name}"

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "${var.cluster_name}"
    location            = "${azurerm_resource_group.k8s.location}"
    resource_group_name = "${azurerm_resource_group.k8s.name}"
    dns_prefix          = "${var.dns_prefix}"

    linux_profile {
        admin_username = "k8s-dev"

        ssh_key {
            key_data = "${file("${var.ssh_public_key}")}"
        }
    }


    dynamic "agent_pool_profile" {
        for_each = var.agent_pools
        content {
            name                = agent_pool_profile.value.name
            count               = agent_pool_profile.value.count
            vm_size             = agent_pool_profile.value.vm_size
            os_type             = agent_pool_profile.value.os_type
            os_disk_size_gb     = agent_pool_profile.value.os_disk_size_gb
            type                = "VirtualMachineScaleSets"
            enable_auto_scaling = agent_pool_profile.value.enable_auto_scaling
            min_count           = agent_pool_profile.value.min_count
            max_count           = agent_pool_profile.value.max_count
            max_pods            = agent_pool_profile.value.max_pods

            # Required for advanced networking
            vnet_subnet_id = "${var.azure_subnet_id}"
        }
    }

    /*
    agent_pool_profile {
        name            = "agentpool"
        count           = "${var.agent_count}"
        vm_size         = "D8s_v3"
        os_type         = "Linux"
        os_disk_size_gb = 30
        
        # Required for advanced networking
        vnet_subnet_id = "${var.azure_subnet_id}"
    }
    */

    service_principal {
        client_id     = "${var.client_id}"
        client_secret = "${var.client_secret}"
    }

    network_profile {
        network_plugin = "azure"
        network_policy = "calico"
        # Required for availability zones
        load_balancer_sku = "standard"
    }

    role_based_access_control {
         enabled = true
    }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = "${azurerm_log_analytics_workspace.test.id}"
        }
    }

    tags = {
       environment = "Development"
    }
}
