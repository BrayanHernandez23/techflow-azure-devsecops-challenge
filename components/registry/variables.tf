variable "resource_group_name" {
  description = "The name of the Azure Resource Group where the Container Registry will be created."
}

variable "location" {
  description = "The Azure region where the Container Registry will be provisioned."
}

variable "project_name" {
  description = "The base name of the project, used to generate the unique ACR name."
}

variable "suffix" {
  description = "A unique alphanumeric suffix to ensure the ACR name is globally unique within Azure."
  default     = ""
}

variable "environment" {
  description = "The deployment environment name used for resource tagging."
  default     = ""
}

variable "identity_principal_id" {
  description = "The principal ID of the identity that will pull images from the ACR."
}