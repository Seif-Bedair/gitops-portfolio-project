resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.prefix}-cluster"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = replace("${var.prefix}registry${random_integer.ri.result}", "-", "")
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "random_integer" "ri" {
  min = 1000
  max = 9999
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-dns"
  oidc_issuer_enabled = true
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s_v2"
    upgrade_settings {
      max_surge = "10%"
    }
  }
  

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}