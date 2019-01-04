# A prefix to use for resources associated with this specific instance
variable "prefix" {
  default = "server16"
}

# Define a NIC for the VM instance to use.
resource "azurerm_network_interface" "nic-main" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.tf.location}"
  resource_group_name = "${azurerm_resource_group.tf.name}"

  ip_configuration {
    name                          = "${var.prefix}-ip"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "dynamic"
  }
}

# Define the Server2016 VM
resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.tf.location}"
  resource_group_name   = "${azurerm_resource_group.tf.name}"
  network_interface_ids = ["${azurerm_network_interface.nic-main.id}"]
  vm_size               = "Standard_D4S_v3"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.prefix}-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.prefix}-host"
    admin_username = "administrator"
    admin_password = "${var.admin_password}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags {
    environment = "dev"
  }
}