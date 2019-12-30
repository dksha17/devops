output "vmids" {
  description = "Virtual machine ids created."
  value       = "${module.frontend.vm_ids}"
}

output "network_interfaces" {
  description = "ids of the vm nics provisoned."
  value       = "${module.frontend.network_interface_ids}"
}

output "vm_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = "${module.frontend.network_interface_private_ip}"
}

output "availability_sets" {
  description = "id of the availability set where the vms are provisioned."
  value       = "${module.frontend.availability_set_id}"
}
