resource "azurerm_container_app_job" "cleanup" {
  name                         = "job-${var.project_name}-cleanup"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  replica_timeout_in_seconds   = 300
  replica_retry_limit          = 1

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  schedule_trigger_config {
    cron_expression = "0 0 * * *"
  }

  template {
    container {
      image   = "alpine:latest"
      name    = "worker"
      command = ["/bin/sh", "-c", "echo 'Job ejecutado con éxito'"]
      cpu     = 0.25
      memory  = "0.5Gi"
    }
  }
}