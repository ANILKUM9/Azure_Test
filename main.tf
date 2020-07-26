variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}
variable "server_location" {}
variable "server_rg" {}
variable "resource_prefix" {}
variable "server_address_space" {}
variable "server_address_prefix" {}
variable "server_name" {}
variable "environment" {}

provider "azurerm" {
  version         = "~> 2.14.0"
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}
# Create Resource Group
resource "azurerm_resource_group" "xoriet" {
  name       = var.server_rg
  location   = var.server_location
  tags = {
    environment = "test"
  }
}
#Create VNET
resource "azurerm_virtual_network" "xoriet" {
  name                = "${var.resource_prefix}-vNET"
  location            = azurerm_resource_group.xoriet.location
  resource_group_name = azurerm_resource_group.xoriet.name
  address_space       = ["${var.server_address_space}"]
  tags = {
    environment = "test"
  }
}
#Create Subnet
resource "azurerm_subnet" "xoriet" {
  name                   = "${var.resource_prefix}-subnet"
  resource_group_name    = azurerm_resource_group.xoriet.name
  virtual_network_name   = azurerm_virtual_network.xoriet.name
  address_prefix         = var.server_address_prefix
}
#Network Interface
resource "azurerm_network_interface" "xoriet" {
  name                  = "${var.server_name}-nic"
  location              = azurerm_resource_group.xoriet.location
  resource_group_name   = azurerm_resource_group.xoriet.name
  ip_configuration {
    name                          = "${var.server_name}-ip"
    subnet_id                     = azurerm_subnet.xoriet.id
    private_ip_address_allocation = "dynamic"  
    public_ip_address_id          = azurerm_public_ip.xoriet.id
  }
  tags = {
    environment = "test"
  }
}
#Create_Public IP
resource "azurerm_public_ip" "xoriet" {
  name                          = "${var.server_name}-public-ip"
  location                      = azurerm_resource_group.xoriet.location
  resource_group_name           = azurerm_resource_group.xoriet.name
  allocation_method             = "Dynamic"
#  allocation_method             = var.environment == "production" ? "Static" : "Dynamic"
  tags = {
    environment = "test"
  }
}
#Create Network Security Group
resource "azurerm_network_security_group" "xoriet"{
  name                          = "${var.server_name}-nsg"
  location                      = azurerm_resource_group.xoriet.location
  resource_group_name           = azurerm_resource_group.xoriet.name
}
#Create Network Security Rule
resource "azurerm_network_security_rule" "xoriet" {
  name                          = "RDP Inbound"
  priority                      = 100
  direction                     = "Inbound"
  access                        = "Allow"
  protocol                      = "TCP"
  source_port_range             = "*"
  destination_port_range        = "3389"
  source_address_prefix         = "*"
  destination_address_prefix    = "*"
  resource_group_name           = azurerm_resource_group.xoriet.name
  network_security_group_name   = azurerm_network_security_group.xoriet.name
}
resource "azurerm_subnet_network_security_group_association" "xoriet" {
  subnet_id                 = azurerm_subnet.xoriet.id
  network_security_group_id = azurerm_network_security_group.xoriet.id
}
#Create Virtual Machine
resource "azurerm_virtual_machine" "xoriet"{
  name                          = "${var.server_name}-nsg"
  location                      = azurerm_resource_group.xoriet.location
  resource_group_name           = azurerm_resource_group.xoriet.name
  network_interface_ids         = [azurerm_network_interface.xoriet.id]
  vm_size                       = "Standard_B1s"
  storage_image_reference{
    publisher       = "MicrosoftWindowsServer"
    offer           = "WindowsServer"
    sku             = "2016-Datacenter-Server-Core-smalldisk"
    version         = "latest"
  }
  storage_os_disk {
    name                          = "${var.server_name}-os"
    caching                       = "ReadWrite"
    create_option                 = "FromImage"
    managed_disk_type             = "Standard_LRS"
  }
  os_profile {
    computer_name       = "hostname"
    admin_username      = "adminuser"
    admin_password      = "Anisha123@123"
  }
  os_profile_windows_config {
  }
}