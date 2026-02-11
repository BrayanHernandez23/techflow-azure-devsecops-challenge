resource "azurerm_container_app_environment" "env" {
  name                = "cae-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}