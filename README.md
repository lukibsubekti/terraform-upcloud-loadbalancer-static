# Terraform - UpCloud - Load Balancer Static


## About
A Terraform module for static load balancer creation in UpCloud.
The module can deploy the load balancer including its backends, frontends, and the frontend rules.
The backend members are set statically by specifying the IPs and ports.


## Requirements
- Terraform version `>= 1.6.0`
- UpCloud Provider version `>= 5.10.0`


## Examples

```hcl
provider "upcloud" {
  username = var.upcloud_username
  password = var.upcloud_password
}
                                        
module "loadbalancer" {
  source  = "lukibsubekti/loadbalancer-static/upcloud"
  version = "1.0.0"

  zone = var.upcloud_zone
  name = "my-loadbalancer"

  private_network = {
    name = "private-net"
    id = "PRIVATE_NETWORK_ID"
  }

  backends = {
    "web1" = [
      {
        ip = "10.0.0.10"
        port = 3001
      },
      {
        ip = "10.0.0.20"
        port = 3002
      },
    ]
    "web2" = [
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
      default_backend = "web1"
    }
    "https" = {
      mode = "http"
      port = 443
      default_backend = "web1"
    }
  }

  rules = {
    "rule1" = {
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
          backend_name = "web1"
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