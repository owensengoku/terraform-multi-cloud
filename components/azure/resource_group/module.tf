
resource "azurerm_resource_group" "rg" {
  name     =var.resource_group_name
  location = var.global_settings.regions[lookup(var.settings, "region", var.global_settings.default_region)]
  tags     = merge(var.tags, lookup(var.settings, "tags", {}))
}
