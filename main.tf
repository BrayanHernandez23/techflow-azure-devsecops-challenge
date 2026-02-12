#import {
#  to = module.compute.azurerm_container_app.api
#  id = "/subscriptions/8e57b1cd-2a2b-4d54-8bc9-f3f06949179c/resourceGroups/rg-techflow-develop/providers/Microsoft.App/containerApps/ca-techflow-api"
#}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
}

module "compute" {
  source                    = "./components/compute"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  project_name              = var.project_name
  environment               = var.environment
  user_assigned_identity_id = module.security.identity_id
  key_vault_secret_id       = module.security.secret_id
  acr_login_server          = module.registry.login_server
}

module "registry" {
  source                = "./components/registry"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  project_name          = var.project_name
  suffix                = var.suffix
  identity_principal_id = module.security.identity_principal_id
}

module "security" {
  source              = "./components/security"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  environment         = var.environment
  suffix              = var.suffix
}