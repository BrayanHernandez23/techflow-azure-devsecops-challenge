variable "resource_group_name" {
  description = "The name of the Azure Resource Group where security resources will be deployed."
}

variable "location" {
  description = "The Azure region where the security resources will be provisioned."
}

variable "project_name" {
  description = "The name of the project, used to derive unique names for the Key Vault and Managed Identity."
}

variable "suffix" {
  description = "A unique alphanumeric suffix to ensure the Key Vault name is globally unique, as required by Azure."
  default     = ""
}

variable "environment" {
  description = "The deployment environment used for resource naming and tagging."
  default     = ""
}