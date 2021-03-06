output vnets {
  depends_on = [azurerm_virtual_network_peering.peering]
  value      = module.networking

}

output public_ip_addresses {
  value = module.public_ip_addresses

}


#
#
# Virtual network
#
#

module "networking" {
  source   = "../../components/azure/virtual_network"
  for_each = local.networking.vnets

  location                          = lookup(each.value, "region", null) == null ? module.resource_groups[each.value.resource_group_key].location : local.global_settings.regions[each.value.region]
  resource_group_name               = module.resource_groups[each.value.resource_group_key].name
  settings                          = each.value
  network_security_group_definition = local.networking.network_security_group_definition
  route_tables                      = module.route_tables
  tags                              = try(each.value.tags, null)
  diagnostics                       = local.combined_diagnostics
  global_settings                   = local.global_settings
  ddos_id                           = try(azurerm_network_ddos_protection_plan.ddos_protection_plan[each.value.ddos_services_key].id, "")
  base_tags                         = try(local.global_settings.inherit_tags, false) ? module.resource_groups[each.value.resource_group_key].tags : {}
  network_watchers                  = try(local.combined_objects_network_watchers, null)
}

#
#
# Public IP Addresses
#
#

# naming convention for public IP address

module public_ip_addresses {
  source   = "../../components/azure/public_ip_addresses"
  for_each = local.networking.public_ip_addresses

  name                       = each.value.name
  resource_group_name        = module.resource_groups[each.value.resource_group_key].name
  location                   = lookup(each.value, "region", null) == null ? module.resource_groups[each.value.resource_group_key].location : local.global_settings.regions[each.value.region]
  sku                        = try(each.value.sku, "Basic")
  allocation_method          = try(each.value.allocation_method, "Dynamic")
  ip_version                 = try(each.value.ip_version, "IPv4")
  idle_timeout_in_minutes    = try(each.value.idle_timeout_in_minutes, null)
  domain_name_label          = try(each.value.domain_name_label, null)
  reverse_fqdn               = try(each.value.reverse_fqdn, null)
  generate_domain_name_label = try(each.value.generate_domain_name_label, false)
  tags                       = try(each.value.tags, null)
  zones                      = try(each.value.zones, null)
  diagnostic_profiles        = try(each.value.diagnostic_profiles, {})
  diagnostics                = local.combined_diagnostics
  base_tags                  = try(local.global_settings.inherit_tags, false) ? module.resource_groups[each.value.resource_group_key].tags : {}
}


#
#
# Vnet peering
#  (Support vnet in remote tfstates)
#


# The code tries to peer to a vnet created in the same landing zone. If it fails it tries with the data remote state
resource "azurerm_virtual_network_peering" "peering" {
  depends_on = [module.networking]
  for_each   = local.networking.vnet_peerings

  name                         = each.value.name
  virtual_network_name         = try(each.value.from.lz_key, null) == null ? local.combined_objects_networking[local.client_config.landingzone_key][each.value.from.vnet_key].name : local.combined_objects_networking[each.value.from.lz_key][each.value.from.vnet_key].name
  resource_group_name          = try(each.value.from.lz_key, null) == null ? local.combined_objects_networking[local.client_config.landingzone_key][each.value.from.vnet_key].resource_group_name : local.combined_objects_networking[each.value.from.lz_key][each.value.from.vnet_key].resource_group_name
  remote_virtual_network_id    = try(each.value.to.lz_key, null) == null ? local.combined_objects_networking[local.client_config.landingzone_key][each.value.to.vnet_key].id : local.combined_objects_networking[each.value.to.lz_key][each.value.to.vnet_key].id
  allow_virtual_network_access = try(each.value.allow_virtual_network_access, true)
  allow_forwarded_traffic      = try(each.value.allow_forwarded_traffic, false)
  allow_gateway_transit        = try(each.value.allow_gateway_transit, false)
  use_remote_gateways          = try(each.value.use_remote_gateways, false)
}

#
#
# Route tables and routes
#
#

module "route_tables" {
  source   = "../../components/azure/route_tables"
  for_each = local.networking.route_tables

  name                          = each.value.name
  resource_group_name           = module.resource_groups[each.value.resource_group_key].name
  location                      = lookup(each.value, "region", null) == null ? module.resource_groups[each.value.resource_group_key].location : local.global_settings.regions[each.value.region]
  disable_bgp_route_propagation = try(each.value.disable_bgp_route_propagation, null)
  tags                          = try(each.value.tags, null)
  base_tags                     = try(local.global_settings.inherit_tags, false) ? module.resource_groups[each.value.resource_group_key].tags : {}
}

module "routes" {
  source   = "../../components/azure/routes"
  for_each = local.networking.azurerm_routes

  name                      = each.value.name
  resource_group_name       = module.resource_groups[each.value.resource_group_key].name
  route_table_name          = module.route_tables[each.value.route_table_key].name
  address_prefix            = each.value.address_prefix
  next_hop_type             = each.value.next_hop_type
  next_hop_in_ip_address    = try(lower(each.value.next_hop_type), null) == "virtualappliance" ? try(each.value.next_hop_in_ip_address, null) : null
  next_hop_in_ip_address_fw = try(lower(each.value.next_hop_type), null) == "virtualappliance" ? try(try(local.combined_objects_azurerm_firewalls[local.client_config.landingzone_key][each.value.private_ip_keys.azurerm_firewall.key].ip_configuration[each.value.private_ip_keys.azurerm_firewall.interface_index].private_ip_address, local.combined_objects_azurerm_firewalls[each.value.lz_key][each.value.private_ip_keys.azurerm_firewall.key].ip_configuration[each.value.private_ip_keys.azurerm_firewall.interface_index].private_ip_address), null) : null
}

#
#
# Azure DDoS
#
#

resource "azurerm_network_ddos_protection_plan" "ddos_protection_plan" {
  for_each = local.networking.ddos_services

  name                = each.value.name
  location            = lookup(each.value, "region", null) == null ? module.resource_groups[each.value.resource_group_key].location : local.global_settings.regions[each.value.region]
  resource_group_name = module.resource_groups[each.value.resource_group_key].name
  tags                = try(local.global_settings.inherit_tags, false) ? merge(module.resource_groups[each.value.resource_group_key].tags, each.value.tags) : try(each.value.tags, null)
}

#
#
# Network Watchers
#
#
module "network_watchers" {
  source   = "../../components/azure/network_watcher"
  for_each = local.networking.network_watchers

  resource_group_name = module.resource_groups[each.value.resource_group_key].name
  location            = lookup(each.value, "region", null) == null ? module.resource_groups[each.value.resource_group_key].location : local.global_settings.regions[each.value.region]
  settings            = each.value
  tags                = try(each.value.tags, null)
  base_tags           = try(local.global_settings.inherit_tags, false) ? module.resource_groups[each.value.resource_group_key].tags : {}
  global_settings     = local.global_settings
}