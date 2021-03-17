
resource "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics.name
  location            = var.global_settings.regions[var.log_analytics.region]
  resource_group_name = var.resource_groups[var.log_analytics.resource_group_key].name
  sku                 = lookup(var.log_analytics, "sku", "PerGB2018")
  retention_in_days   = lookup(var.log_analytics, "retention_in_days", 30)
  tags                = local.tags
}