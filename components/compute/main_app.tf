resource "azurerm_container_app" "api" {
  name                         = "ca-${var.project_name}-api"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.user_assigned_identity_id
  }

  secret {
    name                = "my-secret"
    key_vault_secret_id = var.key_vault_secret_id
    identity            = var.user_assigned_identity_id
  }

  template {
    init_container {
      name    = "init-db-migration"
      image   = "alpine:latest"
      command = ["/bin/sh", "-c", "echo 'Iniciando migración simulada...'; sleep 5; echo 'Listo.'"]
      cpu     = 0.25
      memory  = "0.5Gi"
    }

    container {
      name   = "api-gateway"
      image  = "${var.acr_login_server}/techflow-api:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "MY_SECRET"
        secret_name = "my-secret"
      }
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [
    azurerm_container_app_environment.env
  ]
}