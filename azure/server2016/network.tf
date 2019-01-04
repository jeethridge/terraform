# Create a resource group
resource "azurerm_resource_group" "tf" {
  name     = "terraform"
  location = "East US"
}

# Create a virtual network within the resource group using the vnet module
resource "azurerm_virtual_network" "tf-nw" {
  name                = "terraform-network"
  resource_group_name = "${azurerm_resource_group.tf.name}"
  location            = "${azurerm_resource_group.tf.location}"
  address_space       = ["10.0.0.0/16"]
}

# Define a subnet for the network
resource "azurerm_subnet" "tf-subnet" {
  name                 = "terraform-subnet"
  virtual_network_name = "${azurerm_virtual_network.tf-nw.name}"
  resource_group_name  = "${azurerm_resource_group.tf.name}"
  address_prefix       = "10.0.1.0/24"
}

# Create a public IP for the server to use
resource "azurerm_public_ip" "tf-public-ip" {
  name                         = "terraform-public-ip"
  location                     = "East US"
  resource_group_name          = "${azurerm_resource_group.tf.name}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "dev"
  }
}

# Create a network security group within the resource group
resource "azurerm_network_security_group" "tf-nsg" {
  name                = "terraform-network-security-group"
  location            = "${azurerm_resource_group.tf.location}"
  resource_group_name = "${azurerm_resource_group.tf.name}"
}

# ~~~ Network security rules defined below ~~~

# Allow any outbound
resource "azurerm_network_security_rule" "outbound-nsr" {
  name                        = "Allow Outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.tf.name}"
  network_security_group_name = "${azurerm_network_security_group.tf-nsg.name}"
}

# Allow RDP
resource "azurerm_network_security_rule" "rdp-nsr" {
  name                        = "Allow RDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "${var.management_cidr}"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.tf.name}"
  network_security_group_name = "${azurerm_network_security_group.tf-nsg.name}"
}

# Allow WinRM
resource "azurerm_network_security_rule" "winrm-nsr" {
  name                        = "Allow WinRM"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "5986"
  source_address_prefix       = "${var.management_cidr}"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.tf.name}"
  network_security_group_name = "${azurerm_network_security_group.tf-nsg.name}"
}

# Allow HTTP on Port 8080
resource "azurerm_network_security_rule" "http-nsr" {
  name                        = "Allow HTTP On 8080"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.tf.name}"
  network_security_group_name = "${azurerm_network_security_group.tf-nsg.name}"
}