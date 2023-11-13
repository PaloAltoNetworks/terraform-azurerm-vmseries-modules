resource "azurerm_resource_group" "this" {
  name     = "${var.name_prefix}${var.resource_group_name}"
  location = var.location

  tags = var.tags
}

module "ngfw_metrics" {
  source = "../../modules/ngfw_metrics"

  create_workspace = var.ngfw_metrics.create_workspace

  name                = "${var.ngfw_metrics.create_workspace ? var.name_prefix : ""}${var.ngfw_metrics.name}"
  resource_group_name = var.ngfw_metrics.create_workspace ? azurerm_resource_group.this.name : coalesce(var.ngfw_metrics.resource_group_name, azurerm_resource_group.this.name)
  location            = var.location



  log_analytics_config = {
    sku                       = var.ngfw_metrics.sku
    metrics_retention_in_days = var.ngfw_metrics.metrics_retention_in_days
  }

  application_insights = { for k, v in var.ngfw_metrics.application_insights :
    k => merge(
      v,
      {
        name                      = "${var.name_prefix}${v.name}"
        resource_group_name       = coalesce(v.resource_group_name, azurerm_resource_group.this.name)
        metrics_retention_in_days = v.metrics_retention_in_days
      }
    )
  }

  tags = var.tags

}