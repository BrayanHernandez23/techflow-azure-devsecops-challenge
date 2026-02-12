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
  depends_on = [module.security]
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