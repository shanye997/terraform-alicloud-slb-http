Alibaba Cloud Load Balancer (SLB) HTTP Terraform Module
terraform-alicloud-slb-http
=====================================================================

本 Module 用于在阿里云上快速创建slb http相关资源 

本 Module 支持创建以下资源:

* [Slb Instance](https://www.terraform.io/docs/providers/alicloud/r/slb.html)
* [Slb_Server_Group](https://www.terraform.io/docs/providers/alicloud/r/slb_server_group.html)
* [Slb Listener](https://www.terraform.io/docs/providers/alicloud/r/slb_listener.html)
* [Slb Rule](https://www.terraform.io/docs/providers/alicloud/r/slb_rule.html)

## Terraform 版本

本 Module 要求使用 Terraform 0.12 和 阿里云 Provider 1.56.0+。

## 用法

```hcl
module "slb_http" {
  source  = "terraform-alicloud-modules/slb-http/alicloud"
  profile = "Your-Profile-Name"
  region  = "cn-beijing"
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

* [基础示例](https://github.com/terraform-alicloud-modules/terraform-alicloud-slb-http/tree/master/examples/basic-example)

## 注意事项

* 本 Module 使用的 AccessKey 和 SecretKey 可以直接从 `profile` 和 `shared_credentials_file` 中获取。如果未设置，可通过下载安装 [aliyun-cli](https://github.com/aliyun/aliyun-cli#installation) 后进行配置。

提交问题
-------
如果在使用该 Terraform Module 的过程中有任何问题，可以直接创建一个 [Provider Issue](https://github.com/terraform-providers/terraform-provider-alicloud/issues/new)，我们将根据问题描述提供解决方案。

**注意:** 不建议在该 Module 仓库中直接提交 Issue。

作者
-------
Created and maintained by Wang li(@Lexsss, 13718193219@163.com) and He Guimin(@xiaozhu36, heguimin36@163.com)

许可
----
Apache 2 Licensed. See LICENSE for full details.

参考
---------
* [Terraform-Provider-Alicloud Github](https://github.com/terraform-providers/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://www.terraform.io/docs/providers/alicloud/index.html)
