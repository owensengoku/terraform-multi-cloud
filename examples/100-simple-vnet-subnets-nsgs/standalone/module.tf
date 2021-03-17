module "caf" {
  source          = "../../../modules/caf"
  global_settings = var.global_settings
  resource_groups = var.resource_groups
  tags            = var.tags
  networking = {
    vnets                             = var.vnets
    public_ip_addresses               = var.public_ip_addresses
    network_security_group_definition = var.network_security_group_definition
  }
}

