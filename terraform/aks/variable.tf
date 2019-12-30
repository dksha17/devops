variable "client_id" {}
variable "client_secret" {}

/*
variable "agent_count" {
    default = 5
}
*/

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
    default = "esco-platform"
}

variable cluster_name {
    default = "esco-aks-nonprod-cluster-01"
}

variable resource_group_name {
    default = "esco-aks-nonprod"
}

variable location {
    default = "West US 2"
}

variable log_analytics_workspace_name {
    default = "escoplatformaksdevcluster01"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "westus2"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}

variable azure_subnet_id {
	default = "/subscriptions/a51d82c7-080c-4ccd-867c-c4af37dea0ed/resourceGroups/nonprodtru-usw2-rg/providers/Microsoft.Network/virtualNetworks/az-usw2-nonprodtrusted/subnets/az-usw2-nonprodtrusted-snet"
}

variable "agent_pools" {
  description = "(Optional) List of agent_pools profile for multiple node pools"
  type = list(object({
    name                = string
    count               = number
    vm_size             = string
    os_type             = string
    os_disk_size_gb     = number
    max_pods            = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
  }))
  
  default = [{
    name                = "pool1"
    count               = 3
    vm_size             = "Standard_D8s_v3"
    os_type             = "Linux"
    os_disk_size_gb     = 30
    max_pods            = 30
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
  },
  {
    name                = "pool2"
    count               = 3
    vm_size             = "Standard_D8s_v3"
    os_type             = "Linux"
    os_disk_size_gb     = 30
    max_pods            = 30
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
}]
}
