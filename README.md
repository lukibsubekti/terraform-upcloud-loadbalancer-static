# Terraform - UpCloud - Load Balancer Static


## About
A Terraform module for static load balancer creation in UpCloud.
The module can deploy the load balancer including its backends, frontends, and the frontend rules.
The backend members are set statically by specifying the IPs and ports.


## Requirements
- Terraform version `>= 1.6.0`
- UpCloud Provider version `>= 5.25.0`


## Examples

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    upcloud = {
      source  = "UpCloudLtd/upcloud"
      version = ">= 5.25.0"
    }
  }
}

provider "upcloud" {
  username = var.upcloud_username
  password = var.upcloud_password
}
                                        
module "loadbalancer" {
  source  = "lukibsubekti/loadbalancer-static/upcloud"
  version = "1.0.3"

  zone = var.upcloud_zone
  name = "my-loadbalancer"

  private_network = {
    id = "PRIVATE_NETWORK_ID"
    name = "private-net"
  }

  # public network is optional
  public_network = {
    name = "public-net"
  }

  backends = {
    "SOMENAME1" = [
      {
        ip = "10.0.0.10"
        port = 3001
      },
      {
        ip = "10.0.0.20"
        port = 3002
      },
    ]
    "SOMENAME2" = [
      {
        ip = "10.0.0.30"
        port = 3000
      }
    ]
  }

  frontends = {
    "http" = {
      mode = "http"
      port = 80
      default_backend = "SOMENAME1"
    }
    "https" = {
      mode = "http"
      port = 443
      default_backend = "SOMENAME2"
    }
  }

  rules = {
    "SOMERULE1" = {
      frontend = "http"
      priority = 80
      matching_condition = "or"

      matchers = {
        http_status = [
          {
            method = "greater_or_equal"
            value = 200
          },
          {
            method = "less"
            value = 300
          }
        ]
        request_header = [
          {
            method = "starts"
            name = "Host"
            value = "mywebsite.com"
            ignore_case = true
          },
          {
            method = "starts"
            name = "Host"
            value = "herwebsite.com"
            ignore_case = true
          }
        ]
      }

      actions = {
        use_backend = {
          backend_name = "SOMENAME1"
        }
        set_forwarded_headers = {
          active = true
        }
        set_response_header = [
          {
            header = "X-Engine"
            value = "Strapi"
          },
          {
            header = "X-Frame-Origin"
            value = "SAMEORIGIN"
          }
        ]
      }
    }
  }
}
```

## License

MIT License. See LICENSE for full details.