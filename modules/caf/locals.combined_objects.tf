locals {
  # CAF landing zones can retrieve remote objects from a different landing zone and the
  # combined_objects will merge it with the local objects
  combined_objects_azurerm_firewalls                 = {}
  combined_objects_event_hub_namespaces              = {}
  combined_objects_front_door_waf_policies           = {}
  combined_objects_azuread_applications              = {}
  combined_objects_azuread_groups                    = {}
  combined_objects_mssql_managed_instances           = {}
  combined_objects_mssql_managed_instances_secondary = {}
  combined_objects_mssql_servers                     = {}
  combined_objects_mysql_servers                     = {}
  combined_objects_managed_identities                = {}
  combined_objects_keyvaults                         = merge(tomap({ (local.client_config.landingzone_key) = module.keyvaults }), try(var.remote_objects.keyvaults, {}))
  combined_objects_keyvault_keys                     = merge(tomap({ (local.client_config.landingzone_key) = module.keyvault_keys }), try(var.remote_objects.keyvault_keys, {}))
  # combined_objects_keyvault_certificate_requests     = merge(tomap({ (local.client_config.landingzone_key) = module.keyvault_certificate_requests }), try(var.remote_objects.keyvault_certificate_requests, {}))
  combined_objects_networking                        = merge(tomap({ (local.client_config.landingzone_key) = module.networking }), try(var.remote_objects.vnets, {}))
  combined_objects_network_watchers                  = merge(tomap({ (local.client_config.landingzone_key) = module.network_watchers }), try(var.remote_objects.network_watchers, {}))
  combined_objects_private_dns                       = merge(tomap({ (local.client_config.landingzone_key) = module.private_dns }), try(var.remote_objects.private_dns, {}))
  combined_objects_public_ip_addresses               = merge(tomap({ (local.client_config.landingzone_key) = module.public_ip_addresses }), try(var.remote_objects.public_ip_addresses, {}))
  combined_objects_recovery_vaults                   = {}
  combined_objects_resource_groups                   = merge(tomap({ (local.client_config.landingzone_key) = module.resource_groups }), try(var.remote_objects.resource_groups, {}))
  combined_objects_storage_accounts                  = merge(tomap({ (local.client_config.landingzone_key) = module.storage_accounts }), try(var.remote_objects.storage_accounts, {}))
}