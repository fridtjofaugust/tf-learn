terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.24.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Creating rg for storage
resource "azurerm_resource_group" "storage" {
  name     = "t-learn-storage"
  location = "norwayeast"
}

# Creating storage account
resource "azurerm_storage_account" "stgact" {
  name                     = "tlearnstorage"
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


# Create a resource group
resource "azurerm_resource_group" "vnet-rg" {
  name     = "t-learn-network"
  location = "norwayeast"
}

# Create a virtual network
resource "azurerm_virtual_network" "vpc" {
  name                = "t-learn-vnet"
  resource_group_name = azurerm_resource_group.vnet-rg.name
  location            = azurerm_resource_group.vnet-rg.location
  address_space       = ["10.0.0.0/24"]
}

# Create frontend subnet
resource "azurerm_subnet" "subnet_frontend" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.vnet-rg.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = ["10.0.0.0/25"]
}

# Create backend subnet
resource "azurerm_subnet" "subnet_backend" {
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.vnet-rg.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = ["10.0.0.128/25"]
}

# Create frontend network interface
resource "azurerm_network_interface" "frontend_nic" {
  name                = "frontend_nic"
  location            = azurerm_resource_group.vnet-rg.location
  resource_group_name = azurerm_resource_group.vnet-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_frontend.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create backend network interface
resource "azurerm_network_interface" "backend_nic" {
  name                = "backend_nic"
  location            = azurerm_resource_group.vnet-rg.location
  resource_group_name = azurerm_resource_group.vnet-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_backend.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create LAW
resource "azurerm_resource_group" "law-rg" {
  name     = "t-learn-mon"
  location = "norwayeast"
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "t-learn-law"
  location            = azurerm_resource_group.law-rg.location
  resource_group_name = azurerm_resource_group.law-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Variables

variable "subscriptionid" {
  type    = string
  default = "ff7d3278-59c9-4e96-a409-1bcdf5ac4c88"
}

variable "subscriptionname" {
  type    = string
  default = "t-learn"
}