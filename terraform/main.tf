provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource  "azurerm_resource_group"  "appgrp" {
name  =  "rg-name"
location  =  "North Europe"
}
  
resource  "azurerm_storage_account"  "azurestoragebackend" {
name  =  "azurestoragebackend"
resource_group_name  =  "rg-name"
location  =  "North Europe"
account_tier  =  "Standard"
account_replication_type  =  "LRS"
account_kind  =  "StorageV2"
depends_on  =  [
azurerm_resource_group.appgrp
]
}

resource  "azurerm_storage_container"  "data" {
name  =  "data"
storage_account_name  =  "azurestoragebackend"
container_access_type  =  "blob"
depends_on  =  [
azurerm_storage_account.azurestoragebackend
]
}

resource  "azurerm_storage_blob"  "maintf" {
name  =  "main.tf"
storage_account_name  =  "azurestoragebackend"
storage_container_name  =  "data"
type  =  "Block"
source  =  "main.tf"
depends_on  =  [
azurerm_storage_container.data
]
}



resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resource-group"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name  
  dns_prefix          = "aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2a_v4"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
}
