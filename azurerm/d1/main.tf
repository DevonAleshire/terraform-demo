##################
# Variables
##################
variable azure_subscriptionId {}
variable azure_appId {}
variable azure_password  {}
variable azure_tenant  {}

variable "region" {
  type    = string
  default = "West Us"
}

##################
# Provider
##################
provider "azurerm"{
    features {}
    subscription_id = var.azure_subscriptionId
    client_id       = var.azure_appId  
    client_secret   = var.azure_password
    tenant_id       = var.azure_tenant
}

##################
# Resources
##################
resource "azurerm_resource_group" "tf-demo"{
  name     = "tf-demo-rg"
  location = var.region

  tags = {
    Environment = "Develop"
    Team        = "DevOps"
  }
}

resource "azurerm_virtual_network" "tf-demo"{
  name                = "tf-demo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  resource_group_name = azurerm_resource_group.tf-demo.name
}

resource "azurerm_subnet" "tf-demo"{
  name                 = "tf-demo-subnet"
  resource_group_name  = azurerm_resource_group.tf-demo.name
  virtual_network_name = azurerm_virtual_network.tf-demo.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "tf-demo"{
  name                = "tf-demo-publicip"
  location            = var.region
  resource_group_name = azurerm_resource_group.tf-demo.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "tf-demo"{
  name = "tf-demo-nsg"
  location = var.region
  resource_group_name = azurerm_resource_group.tf-demo.name

  security_rule{
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "tf-demo"{
  name = "tf-demo-nic"
  location = var.region
  resource_group_name = azurerm_resource_group.tf-demo.name

  ip_configuration {
    name                         = "tf-demo-nic-config"
    subnet_id                    = azurerm_subnet.tf-demo.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.tf-demo.id
  }
}

resource "azurerm_linux_virtual_machine" "tf-demo" {
  name                  = "tf-demo-vm"
  resource_group_name   = azurerm_resource_group.tf-demo.name
  location              = var.region
  size                  = "Standard_D1"
  network_interface_ids = [azurerm_network_interface.tf-demo.id]

  admin_username        = "adminuser"
  admin_password        = "Password1234!"
  disable_password_authentication = false

  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("../../.ssh/authorizedkey")
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

    source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}