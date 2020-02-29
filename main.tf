provider "alicloud" {
  profile                 = var.profile != "" ? var.profile : null
  shared_credentials_file = var.shared_credentials_file != "" ? var.shared_credentials_file : null
  region                  = var.region != "" ? var.region : null
  skip_region_validation  = var.skip_region_validation
  configuration_source    = "terraform-alicloud-modules/slb-http"
}

locals {
  http_listeners = [
    for obj in var.http_listeners :
    merge(
      {
        server_group_ids = module.slb.this_slb_virtual_server_group_id
        protocol         = "http"
      },
      obj,
    )
  ]
  https_listeners = [
    for obj in var.https_listeners :
    merge(
      {
        server_group_ids = module.slb.this_slb_virtual_server_group_id
        protocol         = "https"
      },
      obj,
    )
  ]
  create_rule               = var.create_slb || var.use_existing_slb && var.create_rule
  create_server_certificate = var.create_slb || var.use_existing_slb && var.create_server_certificate
  server_certificate        = lookup(var.ssl_certificates, "server_certificate", "")
  private_key               = lookup(var.ssl_certificates, "private_key", "")
  server_certificate_id     = lookup(var.ssl_certificates, "server_certificate_id", concat(alicloud_slb_server_certificate.this.*.id, [""])[0])
  ssl_certificates = merge(
    {
      server_certificate_id = local.server_certificate_id
    },
    var.ssl_certificates,
  )
}

// Slb Module
module "slb" {
  source                          = "alibaba/slb/alicloud"
  region                          = var.region
  profile                         = var.profile
  shared_credentials_file         = var.shared_credentials_file
  skip_region_validation          = var.skip_region_validation
  use_existing_slb                = var.use_existing_slb
  existing_slb_id                 = var.existing_slb_id
  create                          = var.create_slb
  name                            = "TF-slb-http-module"
  address_type                    = var.address_type
  internet_charge_type            = var.internet_charge_type
  spec                            = var.spec
  bandwidth                       = var.bandwidth
  master_zone_id                  = var.master_zone_id
  slave_zone_id                   = var.slave_zone_id
  virtual_server_group_name       = var.virtual_server_group_name
  servers_of_virtual_server_group = var.servers_of_virtual_server_group
  tags = merge(
    {
      Create = "terraform-alicloud-slb-http-module"
    },
    var.tags,
  )
}

module "slb_http_listener" {
  source                  = "terraform-alicloud-modules/slb-listener/alicloud"
  create                  = var.create_slb || var.use_existing_slb ? var.create_http_listener : false
  profile                 = var.profile
  region                  = var.region
  shared_credentials_file = var.shared_credentials_file
  skip_region_validation  = var.skip_region_validation
  slb                     = module.slb.this_slb_id
  listeners               = local.http_listeners
  health_check            = var.health_check
  advanced_setting        = var.advanced_setting
  x_forwarded_for         = var.x_forwarded_for
}

module "slb_https_listener" {
  source                  = "terraform-alicloud-modules/slb-listener/alicloud"
  create                  = var.create_slb || var.use_existing_slb ? var.create_https_listener : false
  profile                 = var.profile
  region                  = var.region
  shared_credentials_file = var.shared_credentials_file
  skip_region_validation  = var.skip_region_validation
  slb                     = module.slb.this_slb_id
  listeners               = local.https_listeners
  health_check            = var.health_check
  advanced_setting        = var.advanced_setting
  x_forwarded_for         = var.x_forwarded_for
  ssl_certificates        = local.ssl_certificates
}

resource "alicloud_slb_rule" "this" {
  count            = local.create_rule ? length(var.rules) : 0
  load_balancer_id = module.slb.this_slb_id
  name             = "TF-slb-http-module"
  listener_sync    = "on"
  domain           = lookup(var.rules[count.index], "domain", null)
  url              = lookup(var.rules[count.index], "url", null)
  frontend_port    = lookup(var.rules[count.index], "frontend_port")
  server_group_id  = module.slb.this_slb_virtual_server_group_id
  depends_on       = [module.slb_http_listener, module.slb_https_listener]
}

resource "alicloud_slb_server_certificate" "this" {
  count              = local.create_server_certificate && local.server_certificate != "" && local.private_key != "" ? 1 : 0
  name               = "TF-slb-http-module"
  server_certificate = contains(split("\n", local.server_certificate), "-----BEGIN CERTIFICATE-----") ? local.server_certificate : file(local.server_certificate)
  private_key        = contains(split("\n", local.private_key), "-----BEGIN RSA PRIVATE KEY-----") ? local.private_key : file(local.private_key)
}
