output "login_server" {
  description = "The URL that can be used to log into the container registry. This is required for Docker authentication and image tagging in the CI/CD pipeline."
  value       = azurerm_container_registry.acr.login_server
}