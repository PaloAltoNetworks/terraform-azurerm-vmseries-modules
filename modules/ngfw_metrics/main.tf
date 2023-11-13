# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
resource "azurerm_log_analytics_workspace" "this" {
  count = var.create_workspace ? 1 : 0

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  retention_in_days = var.log_analytics_config.metrics_retention_in_days
  sku               = var.log_analytics_config.sku

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace
data "azurerm_log_analytics_workspace" "this" {
  count = var.create_workspace ? 0 : 1

  name                = var.name
  resource_group_name = var.resource_group_name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights
resource "azurerm_application_insights" "this" {
  for_each = var.application_insights

  name                = each.value.name
  resource_group_name = coalesce(each.value.resource_group_name, var.resource_group_name)
  location            = var.location

  workspace_id      = var.create_workspace ? azurerm_log_analytics_workspace.this[0].id : data.azurerm_log_analytics_workspace.this[0].id
  application_type  = "other"
  retention_in_days = each.value.metrics_retention_in_days == null ? var.log_analytics_config.metrics_retention_in_days : each.value.metrics_retention_in_days

  tags = var.tags
}
