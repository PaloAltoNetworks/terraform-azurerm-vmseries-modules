resource "azurerm_log_analytics_workspace" "this" {
  count = var.workspace_mode ? 1 : 0

  name     = try(var.workspace_name, "${var.name}-wrkspc")
  location = var.location

  resource_group_name = var.resource_group_name
  retention_in_days   = var.metrics_retention_in_days
  sku                 = var.workspace_sku

  tags = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name # same RG, so no RBAC modification is needed

  workspace_id      = var.workspace_mode ? azurerm_log_analytics_workspace.this[0].id : null
  application_type  = "other"
  retention_in_days = var.metrics_retention_in_days

  tags = var.tags
}
