data "azurerm_availability_set" "myterraformavailset" {
  name                = "${var.availability_set}"
  resource_group_name = "${var.resource_group_name}"
}
# Create network interface.
resource "azurerm_network_interface" "myterraformnic" {
  name                = "${var.NIC_Name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.NIC_Name}_IP"
    subnet_id                     = "${var.subnet}"
    private_ip_address_allocation = "Dynamic"
  }
}
# Generate random text for a unique storage account name.
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined.
    resource_group_name = "${var.resource_group_name}"
  }
  byte_length = 8
}
# Create storage account for boot diagnostics.
resource "azurerm_storage_account" "mystorageaccount" {
  count                    = "${var.boot_diagnostics == "true" ? 1 : 0}"
  name                     = "bootdiag${random_id.randomId.hex}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  account_tier             = "${element(split("_", var.Storage_Account_Tier), 0)}"
  account_replication_type = "${element(split("_", var.Storage_Account_Tier), 1)}"
}
# Create virtual machine.
resource "azurerm_virtual_machine" "myterraformvm" {
  name                             = "${var.Machine_Name}"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group_name}"
  network_interface_ids            = ["${azurerm_network_interface.myterraformnic.id}"]
  vm_size                          = "${var.Machine_size}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = false
  availability_set_id              = "${data.azurerm_availability_set.myterraformavailset.id}"

  storage_os_disk {
    name              = "${var.Disk_Name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "datadisk_${random_id.randomId.hex}"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "${var.data_disk_size_gb}"
  }
  storage_image_reference {
    id = "${var.Machine_Image_name}"
  }
  os_profile {
    computer_name  = "${var.Machine_Name}"
    admin_username = "${var.User_Name}"
    admin_password = "${var.Password}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = "${var.tags}"

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.mystorageaccount.*.primary_blob_endpoint) : ""}"
  }

  #}
  #Puppet script copy
  #resource "null_resource" "null" {
  provisioner "file" {
    connection {
      type     = "ssh"
      user     = "${var.User_Name}"
      password = "${var.Password}"
      host     = "${azurerm_network_interface.myterraformnic.private_ip_address}"
    }
    source      = "install.bash"
    destination = "/tmp/install.bash"
  }
  # Connect to provisioned VM.
  connection {
    type     = "ssh"
    user     = "${var.User_Name}"
    password = "${var.Password}"
    host     = "${azurerm_network_interface.myterraformnic.private_ip_address}"
  }
  # Install and configure Docker.
  provisioner "remote-exec" {
    inline = [
      "echo '${var.Password}' | sudo -S systemctl stop firewalld",
      "echo '${var.Password}' | sudo -S wget -O /tmp/docker-18.06.3-ce.tgz https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz",
      "echo '${var.Password}' | sudo -S tar -C /tmp -xzvf /tmp/docker-18.06.3-ce.tgz",
      "echo '${var.Password}' | sudo -S cp -R /tmp/docker/* /usr/bin/",
      "echo '${var.Password}' | sudo -S dockerd &",
      "echo '${var.Password}' | sudo -S dockerd &",
      "echo '${var.Password}' | sudo -S groupadd docker",
      "echo '${var.Password}' | sudo -S useradd esff-prod",
      "echo '${var.Password}' | sudo -S useradd ea00ad-prod",
      "echo '${var.Password}' | sudo -S usermod -a -G docker esff-prod",
      "echo '${var.Password}' | sudo -S usermod -a -G docker ea00ad-prod",
      "echo '${var.Password}' | sudo -S setfacl -m user:esff-prod:rw /var/run/docker.sock",
      "echo '${var.Password}'| sudo -S setfacl -m user:ea00ad-prod:rw /var/run/docker.sock",
      "cp /etc/hosts /tmp/hosts",
      "echo '172.21.44.87 zduwesghepuppentmaster.reddog.microsoft.com' >> /tmp/hosts",
      "echo '${var.Password}'|sudo -S cp /tmp/hosts /etc/hosts",
      "echo '${var.Password}'| sudo -S chmod 777 /tmp/install.bash",
      "echo '${var.Password}'| sudo -S yum install puppet-agent -y",
      "echo '${var.Password}'| sudo -S bash /tmp/install.bash"
    ]
  }
}

  resource "azurerm_recovery_services_protected_vm" "vm" {
    resource_group_name = "${var.resource_group_name}"
    recovery_vault_name = "${var.recovery_services_vault_name}"
    source_vm_id        = "${azurerm_virtual_machine.myterraformvm.id}"
    backup_policy_id    = "${var.recovery_services_protection_policy_id}"
  }
