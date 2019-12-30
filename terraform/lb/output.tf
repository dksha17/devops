 output "public_ip" {
  description = "public_ip"
  value       = "${azurerm_public_ip.sw.ip_address}"
}
