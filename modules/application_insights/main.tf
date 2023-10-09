resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name

  retention_in_days = var.metrics_retention_in_days
  sku               = var.workspace_sku

  tags = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name # same RG, so no RBAC modification is needed

  workspace_id      = azurerm_log_analytics_workspace.this.id
  application_type  = "other"
  retention_in_days = var.metrics_retention_in_days

  tags = var.tags
}
