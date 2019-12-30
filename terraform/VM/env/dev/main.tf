# Configure the Azure Provider
provider "azurerm" {
  version = "=1.33.1"
}

# Configure the Azure backend (blob storage)
terraform {
  backend "azurerm" {
    #resource_group_name = "*****"
    storage_account_name = "******"
    container_name       = "***"
    key                  = "******"
    access_key           = "****"
  }
}

variable "region" {}
variable "region_code" {}
variable "service_code" {}
variable "app" {}
variable "resource_group_name" {}
#variable "subnet" {}
#variable "nb_instances" {}

locals {
 #region              = "West US"
 #region_code         = "zduw"
 #service_code        = "esgh"
 #app                 = "test"
 #resource_group_name = "platform_esgh_sandbox_nonprod_rg"
  subnet              = "/subscriptions/"
  vm_size             = "Standard_DS1_V2"
  vm_os               = "RHEL"
  vm_os_id            = "/subscriptions/5cdb8a38-5edf-4090-9e49-c28ecb16d982/resourceGroups/infrastructure/providers/Microsoft.Compute/galleries/alb_shared_images/images/RHEL7-2019.r03/versions/0.0.1"
}

module "frontend" {
  source                        = "../../modules/virtual_machine/"
  #resource_group_name           = "${local.resource_group_name}"
  resource_group_name           = "${var.resource_group_name}"
  vnet_subnet_id                = "${local.subnet}"
  #location                      = "${local.region}"
  location                      = "${var.region}"
  vm_size                       = "${local.vm_size}"
  nb_instances                  = 1
  #vm_hostname                   = "${local.region_code}-${local.service_code}-${local.app}"
  vm_hostname                   = "${var.region_code}-${var.service_code}-${var.app}"
  vm_os                         = "${local.vm_os}"
  vm_os_id                      = "${local.vm_os_id}"
  is_windows_image              = "false"
  delete_os_disk_on_termination = "true"
  data_disk                     = "false" #if it is true we need to specify data_disk_size_gb value also
}
