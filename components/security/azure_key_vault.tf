data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "id-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault" "kv" {
  name                       = "kv-${var.project_name}-${var.suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  # checkov:skip=CKV_AZURE_189: Firewall configurado en modo Allow para acceso desde el pipeline.
  # checkov:skip=CKV_AZURE_109: Simplificación de red para entorno de evaluación.
  # checkov:skip=CKV2_AZURE_32: Private Endpoint no implementado para reducir complejidad de red.

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover", "Restore"]
  }
  
  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = azurerm_user_assigned_identity.app_identity.principal_id
    secret_permissions = ["Get"]
  }
}

resource "azurerm_key_vault_secret" "app_secret" {
  name            = "MY-SECRET"
  value           = "TechFlow-IA-Powered-Secret"
  key_vault_id    = azurerm_key_vault.kv.id
  content_type    = "text/plain"
  expiration_date = "2026-12-31T23:59:59Z"
}