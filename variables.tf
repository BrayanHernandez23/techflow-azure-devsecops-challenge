variable "resource_group_name" {

  description = "The name of the Azure Resource Group where all project resources will be organized."

}

variable "location" {

  description = "The Azure region where the resources will be deployed."

}

variable "project_name" {

  description = "The name of the project, used as a prefix for naming all related Azure resources."

}

variable "suffix" {

  description = "A unique alphanumeric suffix to ensure global uniqueness for services like Key Vault and ACR."
  default     = ""

}

variable "environment" {

  description = "The deployment environment name used to manage resource configurations and tags."
  default     = ""

}