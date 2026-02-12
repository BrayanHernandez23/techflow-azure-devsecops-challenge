resource "azurerm_container_registry" "acr" {
  name                = "acr${var.project_name}${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  # checkov:skip=CKV_AZURE_166: Se usa SKU Basic por costos de la prueba técnica.
  # checkov:skip=CKV_AZURE_139: Acceso público permitido para simplificar despliegue de la prueba.
  # checkov:skip=CKV_AZURE_233: Resiliencia de zona no requerida para este entorno.
  # checkov:skip=CKV_AZURE_163: Vulnerability scanning requiere SKU Premium.
  # checkov:skip=CKV_AZURE_167: Retention policy requiere SKU Premium.
  # checkov:skip=CKV_AZURE_164: Image signing no implementado en esta fase.
  # checkov:skip=CKV_AZURE_237: Dedicated data endpoints requieren SKU Premium.
  # checkov:skip=CKV_AZURE_165: Geo-replication no requerida para el reto.
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = var.identity_principal_id
}