terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
 backend "azurerm" {
      resource_group_name  = "my-terraform-rg"
      storage_account_name = "mytfstateforazure"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }
  
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resource-group"
  location = "westeurope"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name  
  dns_prefix          = "aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "standard_dc2s_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}


