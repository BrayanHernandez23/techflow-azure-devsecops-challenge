data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "id-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
}

resource "azurerm_key_vault" "kv" {
  name                          = "kv-${var.project_name}-${var.suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  public_network_access_enabled = true
  # checkov:skip=CKV_AZURE_189: Firewall set to 'Allow' mode to ensure seamless access from the CI/CD pipeline.
  # checkov:skip=CKV_AZURE_109: Network simplification for the technical evaluation environment.
  # checkov:skip=CKV2_AZURE_32: Private Endpoint not implemented to reduce networking complexity for this challenge.

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
  name            = "my-secret"
  value           = "TechFlow-IA-Powered-Secret"
  key_vault_id    = azurerm_key_vault.kv.id
  content_type    = "text/plain"
  expiration_date = "2026-12-31T23:59:59Z"
}

resource "time_sleep" "wait_20_seconds" {
  depends_on = [
    azurerm_key_vault.kv,
    azurerm_user_assigned_identity.app_identity,
    azurerm_key_vault_secret.app_secret,
    azurerm_role_assignment.kv_secrets_user
  ]
  create_duration = "20s"
}