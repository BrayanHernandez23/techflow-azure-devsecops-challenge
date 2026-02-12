variable "resource_group_name" {
  description = "The name of the Azure Resource Group where the container app resources will be deployed."
}

variable "location" {
  description = "The Azure region where the compute resources will be provisioned."
}

variable "project_name" {
  description = "The name of the project, used for resource naming and tagging purposes."
}

variable "environment" {
  description = "The deployment environment to distinguish resource naming and configurations."
}

variable "user_assigned_identity_id" {
  description = "The Resource ID of the User Assigned Managed Identity created in the security module, used by the container app to access Key Vault."
}

variable "key_vault_secret_id" {
  description = "The Versionless ID of the Azure Key Vault secret to be injected as an environment variable into the container app."
}

variable "acr_login_server" {
  description = "The fully qualified login server URL of the Azure Container Registry where the application image is hosted."
}