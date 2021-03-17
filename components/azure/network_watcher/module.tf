
resource "azurerm_network_watcher" "netwatcher" {
  name                = var.settings.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}
