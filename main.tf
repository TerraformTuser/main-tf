# Azure Provider Configuration
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.17.0"
    }
  }
}
provider "azurerm" {
  subscription_id = "546252b0-5718-491e-99fc-cce062d808d9"
  client_id = "50e755a9-0989-4cea-9b39-c84add1e25df"
  client_secret = "OC_8Q~sbsBRPy.nTexgoN9uG1UDK-8jZGbbSzdta"
  tenant_id = "d2bda36d-c5d4-4a6c-b4d3-a5b291dd98e0"
  features {
    
  }
}


resource "azurerm_resource_group" "example" {
  name     = "TEST-RG"
  location = "East US"
}

resource "azurerm_virtual_network" "main" {
  name                = "TES_-VNET"
  address_space       = ["10.16.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "internal" {
  name                 = "TEST-SUBNET"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.16.2.0/24"]
}

resource "azurerm_subnet" "internal1" {
  name                 = "TEST-SUBNET1"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.16.3.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "TEST-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

 
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id


  }

}
resource "azurerm_public_ip" "example" {
  name                = "TEST-VM-pip"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.example.name

  allocation_method   = "Static" 
}
 


resource "azurerm_virtual_machine" "main" {
  name                  = "TEST-VM"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}