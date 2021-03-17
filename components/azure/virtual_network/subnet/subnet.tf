
resource "azurerm_subnet" "subnet" {

  name                                           = var.name
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = var.virtual_network_name
  address_prefixes                               = var.address_prefixes
  service_endpoints                              = var.service_endpoints
  enforce_private_link_endpoint_network_policies = try(var.enforce_private_link_endpoint_network_policies, false)
  enforce_private_link_service_network_policies  = try(var.enforce_private_link_service_network_policies, false)

  dynamic "delegation" {
    for_each = try(var.settings.delegation, null) == null ? [] : [1]

    content {
      name = var.settings.delegation.name

      service_delegation {
        name    = var.settings.delegation.service_delegation
        actions = lookup(var.settings.delegation, "actions", null)
      }
    }
  }

}