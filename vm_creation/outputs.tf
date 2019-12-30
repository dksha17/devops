output "private_ip" {
  description = "private ip addresses of the vm nics"
  value       = "${azurerm_network_interface.myterraformnic.*.private_ip_address}"
}
