
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_links" {
  for_each = var.vnet_links

  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = try(var.vnets[var.client_config.landingzone_key][each.value.vnet_key].id, var.vnets[each.value.lz_key][each.value.vnet_key].id)
  registration_enabled  = try(each.value.registration_enabled, false)
  tags                  = merge(var.base_tags, local.module_tag, try(each.value.tags, null))
}