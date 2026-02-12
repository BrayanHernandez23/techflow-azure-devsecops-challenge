output "identity_id" {
  description = "The Resource ID of the User Assigned Managed Identity. This ID is required by the Container App to authenticate against Azure Key Vault without credentials."
  value       = azurerm_user_assigned_identity.app_identity.id
  depends_on  = [time_sleep.wait_90_seconds]
}

output "secret_id" {
  description = "The Versionless ID of the Key Vault secret. Using the versionless ID ensures the application always retrieves the latest enabled version of the secret."
  value       = azurerm_key_vault_secret.app_secret.versionless_id
  depends_on  = [time_sleep.wait_90_seconds]
}

output "identity_principal_id" {
  description = "The Principal ID of the Managed Identity, required for Role Assignments."
  value       = azurerm_user_assigned_identity.app_identity.principal_id
  depends_on  = [time_sleep.wait_90_seconds]
}