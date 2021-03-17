
resource "azurerm_eventhub_authorization_rule" "evhub_rule" {
  name                = var.settings.rule_name
  namespace_name      = var.namespace_name
  eventhub_name       = var.eventhub_name
  resource_group_name = var.resource_group_name
  listen              = var.settings.listen
  send                = var.settings.send
  manage              = var.settings.manage
}