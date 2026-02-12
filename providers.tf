terraform {

  required_version = ">= 1.11.0"

  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.15"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  use_msi                         = false
  use_cli                         = false
  resource_provider_registrations = "core"
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {}