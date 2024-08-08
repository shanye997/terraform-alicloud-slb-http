# 下线公告

感谢您对阿里云 Terraform Module 的关注，即日起，本 Module 将停止维护并会在将来正式下线。推荐您使用 [terraform-alicloud-slb](https://registry.terraform.io/modules/alibaba/slb/alicloud/latest) 作为替代方案。更多丰富的 Module 可在 [阿里云 Terraform Module](https://registry.terraform.io/browse/modules?provider=alibaba) 中搜索获取。

再次感谢您的理解和合作。


Alibaba Cloud Load Balancer (SLB) HTTP Terraform Module
terraform-alicloud-slb-http
=====================================================================

本 Module 用于在阿里云上快速创建slb http相关资源 

本 Module 支持创建以下资源:

* [Slb Instance](https://www.terraform.io/docs/providers/alicloud/r/slb.html)
* [Slb_Server_Group](https://www.terraform.io/docs/providers/alicloud/r/slb_server_group.html)
* [Slb Listener](https://www.terraform.io/docs/providers/alicloud/r/slb_listener.html)
* [Slb Rule](https://www.terraform.io/docs/providers/alicloud/r/slb_rule.html)

## 用法

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
    // server_certificate_id = "118272523xxxxxx_16fdb8408c8_-662893411_xxxxxxx"
    
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

## 示例

* [基础示例](https://github.com/terraform-alicloud-modules/terraform-alicloud-slb-http/tree/master/examples/complete)

## 注意事项
本Module从版本v1.1.0开始已经移除掉如下的 provider 的显式设置：

```hcl
provider "alicloud" {
  profile                 = var.profile != "" ? var.profile : null
  shared_credentials_file = var.shared_credentials_file != "" ? var.shared_credentials_file : null
  region                  = var.region != "" ? var.region : null
  skip_region_validation  = var.skip_region_validation
  configuration_source    = "terraform-alicloud-modules/slb-http"
}
```

如果你依然想在Module中使用这个 provider 配置，你可以在调用Module的时候，指定一个特定的版本，比如 1.0.0:

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

如果你想对正在使用中的Module升级到 1.1.0 或者更高的版本，那么你可以在模板中显式定义一个相同Region的provider：
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
或者，如果你是多Region部署，你可以利用 `alias` 定义多个 provider，并在Module中显式指定这个provider：

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

定义完provider之后，运行命令 `terraform init` 和 `terraform apply` 来让这个provider生效即可。

更多provider的使用细节，请移步[How to use provider in the module](https://www.terraform.io/docs/language/modules/develop/providers.html#passing-providers-explicitly)

## Terraform 版本

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.56.0 |

提交问题
-------
如果在使用该 Terraform Module 的过程中有任何问题，可以直接创建一个 [Provider Issue](https://github.com/terraform-providers/terraform-provider-alicloud/issues/new)，我们将根据问题描述提供解决方案。

**注意:** 不建议在该 Module 仓库中直接提交 Issue。

作者
-------
Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com)

许可
----
Apache 2 Licensed. See LICENSE for full details.

参考
---------
* [Terraform-Provider-Alicloud Github](https://github.com/terraform-providers/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://www.terraform.io/docs/providers/alicloud/index.html)