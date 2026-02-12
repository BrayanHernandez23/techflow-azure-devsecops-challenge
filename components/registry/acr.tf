resource "azurerm_container_registry" "acr" {
  name                = "acr${var.project_name}${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  # checkov:skip=CKV_AZURE_166: Basic SKU is used to optimize costs for this technical challenge.
  # checkov:skip=CKV_AZURE_139: Public access enabled to simplify deployment and testing for evaluation purposes.
  # checkov:skip=CKV_AZURE_233: Zone resiliency not required for this non-production environment.
  # checkov:skip=CKV_AZURE_163: Vulnerability scanning requires Premium SKU, exceeding challenge cost scope.
  # checkov:skip=CKV_AZURE_167: Retention policy requires Premium SKU.
  # checkov:skip=CKV_AZURE_164: Image signing not implemented in this phase of the project.
  # checkov:skip=CKV_AZURE_237: Dedicated data endpoints require Premium SKU.
  # checkov:skip=CKV_AZURE_165: Geo-replication not required for the current challenge scope.
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = var.identity_principal_id
}