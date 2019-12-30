variable "resource_group_name" {}
#variable "vnet" {}
variable "subnet" {}
variable "location" {}
variable "Machine_Name" {}
variable "Machine_size" {}
variable "Machine_Image_name" {}
variable "NIC_Name" {}
#variable "Network_Security_Group" {}
variable "Storage_Account_Tier" {}
variable "Disk_Name" {}
variable "data_disk_size_gb" {
  description = "data disk size in GB"
  default     = "120"
}
variable "boot_diagnostics" {
  description = "boot diagnostic store in the blob storage"
  default = "true"
}
variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "recovery_services_protection_policy_id" {}
variable "recovery_services_vault_name" {}
variable "User_Name" {}
variable "Password" {}
variable "availability_set" {}
