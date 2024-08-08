# Deprecated

Thank you for your interest in Alibaba Cloud Terraform Module. This Module will be out of maintenance as of today and will be officially taken offline in the future. We recommend you to use [terraform-alicloud-slb](https://registry.terraform.io/modules/alibaba/slb/alicloud/latest) as an alternative. More available Modules can be searched in [Alibaba Cloud Terraform Module](https://registry.terraform.io/browse/modules?provider=alibaba).

Thank you again for your understanding and cooperation.


Alibaba Cloud Load Balancer (SLB) HTTP Terraform Module
terraform-alicloud-slb-http
=====================================================================

English | [简体中文](https://github.com/terraform-alicloud-modules/terraform-alicloud-slb-http/blob/master/README-CN.md)

Terraform module which creates slb http resources on Alibaba Cloud.

These types of resources are supported:

* [Slb Instance](https://www.terraform.io/docs/providers/alicloud/r/slb.html)
* [Slb_Server_Group](https://www.terraform.io/docs/providers/alicloud/r/slb_server_group.html)
* [Slb Listener](https://www.terraform.io/docs/providers/alicloud/r/slb_listener.html)
* [Slb Rule](https://www.terraform.io/docs/providers/alicloud/r/slb_rule.html)

## Usage

```hcl
module "slb_http" {
  source  = "terraform-alicloud-modules/slb-http/alicloud"
  create_slb           = true
  create_http_listener = true
  spec                 = "slb.s2.small"
  
  #########################
  #HTTP listeners creation#
  #########################
  http_listeners = [
    {
      backend_port      = "80"
      frontend_port     = "80"
      bandwidth         = "-1"
      scheduler         = "wrr"
      healthy_threshold = "4"
      gzip              = "false"
    }
  ]
  
  ##########################
  #HTTPS listeners creation#
  ##########################
  https_listeners = [
    {
      backend_port      = "80"
      frontend_port     = "80"
      bandwidth         = "-1"
      scheduler         = "wrr"
      healthy_threshold = "4"
      gzip              = "false"
    }
  ]
  
  ########################
  #attach virtual servers#
  ########################
  servers_of_virtual_server_group = [
    {
      server_ids = "i-bp1xxxxxxxxxx1,i-bp1xxxxxxxxxx2"
      port       = "80"
      weight     = "100"
      type       = "ecs"
    },
    // Using default value
    {
      server_ids = "i-bp1xxxxxxxxxx3"
    }
  ]
  
  ##########################
  #ssl_certificates setting#
  ##########################
  ssl_certificates = {
    tls_cipher_policy  = "tls_cipher_policy_1_2"
    // you can specify the field 'server_certificate_id' to create listeners, field 'server_certificate' and 'private_key' will be ignore.
    // server_certificate_id = "1182725xxxxxx_16fdb8408c8_-662893411_xxxxxxx"
    
    // you can specify file path to field 'server_certificate' and 'private_key'
    server_certificate = "-----BEGIN CERTIFICATE-----\nMIIDRjCCAq+g...\n-----END CERTIFICATE-----"
    private_key        = "-----BEGIN RSA PRIVATE KEY-----\nMIICXAIBA...\n-----END RSA PRIVATE KEY-----"
  }
  
  ###################
  #slb rule creation#
  ###################
  rules = [
    //rule with domain
    {
      domain        = "*.aliyun.com"
      frontend_port = "80"
    },
    //rule with url
    {
      url           = "/image"
      frontend_port = "80"
    },
    //rule with both domain and url
    {
      domain        = "*.aliyun.com"
      url           = "/image"
      frontend_port = "80"
    }
  ]
  
  // health_check will apply to all of listeners if health checking is not set in the listeners
  health_check = {
    health_check              = "on"
    health_check_type         = "tcp"
    healthy_threshold         = "3"
    unhealthy_threshold       = "2"
    health_check_timeout      = "5"
    health_check_interval     = "2"
    health_check_connect_port = "80"
    health_check_uri          = "/"
    health_check_http_code    = "http_2xx"
  }
  
  // advanced_setting will apply to all of listeners if some fields are not set in the listeners
  advanced_setting = {
    sticky_session      = "on"
    sticky_session_type = "server"
    cookie_timeout      = "86400"
    gzip                = "false"
    retrive_slb_ip      = "true"
    retrive_slb_id      = "false"
    retrive_slb_proto   = "true"
    persistence_timeout = "5"
  }
  
  // x_forwarded_for will apply to all of listeners if it is not set in the listeners
  x_forwarded_for = {
    retrive_slb_ip    = "true"
    retrive_slb_id    = "false"
    retrive_slb_proto = "true"
  }
}

```

## Examples

* [Basic example](https://github.com/terraform-alicloud-modules/terraform-alicloud-slb-http/tree/master/examples/complete)

## Notes
From the version v1.1.0, the module has removed the following `provider` setting:

```hcl
provider "alicloud" {
  profile                 = var.profile != "" ? var.profile : null
  shared_credentials_file = var.shared_credentials_file != "" ? var.shared_credentials_file : null
  region                  = var.region != "" ? var.region : null
  skip_region_validation  = var.skip_region_validation
  configuration_source    = "terraform-alicloud-modules/slb-http"
}
```

If you still want to use the `provider` setting to apply this module, you can specify a supported version, like 1.0.0:

```hcl
module "slb_http" {
  source               = "terraform-alicloud-modules/slb-http/alicloud"
  version              = "1.0.0"
  region               = "cn-beijing"
  profile              = "Your-Profile-Name"
  create_slb           = true
  create_http_listener = true
  // ...
}
```

If you want to upgrade the module to 1.1.0 or higher in-place, you can define a provider which same region with
previous region:

```hcl
provider "alicloud" {
  region  = "cn-beijing"
  profile = "Your-Profile-Name"
}
module "slb_http" {
  source               = "terraform-alicloud-modules/slb-http/alicloud"
  create_slb           = true
  create_http_listener = true
  // ...
}
```
or specify an alias provider with a defined region to the module using `providers`:

```hcl
provider "alicloud" {
  region  = "cn-beijing"
  profile = "Your-Profile-Name"
  alias   = "bj"
}
module "slb_http" {
  source               = "terraform-alicloud-modules/slb-http/alicloud"
  providers = {
    alicloud = alicloud.bj
  }
  create_slb           = true
  create_http_listener = true
  // ...
}
```

and then run `terraform init` and `terraform apply` to make the defined provider effect to the existing module state.

More details see [How to use provider in the module](https://www.terraform.io/docs/language/modules/develop/providers.html#passing-providers-explicitly)

## Terraform versions

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.56.0 |

Submit Issues
-------------
If you have any problems when using this module, please opening a [provider issue](https://github.com/terraform-providers/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There does not recommend to open an issue on this repo.

Authors
-------
Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com)

License
----
Apache 2 Licensed. See LICENSE for full details.

Reference
---------
* [Terraform-Provider-Alicloud Github](https://github.com/terraform-providers/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://www.terraform.io/docs/providers/alicloud/index.html)