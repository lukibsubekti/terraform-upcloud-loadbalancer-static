resource "upcloud_loadbalancer" "main" {
  configured_status = "started"
  name              = var.name        # required
  plan              = var.plan     # required
  zone              = var.zone  # required

  networks {
    name   = "public-net"
    type   = "public"
    family = "IPv4"
  }

  dynamic "networks" {
    for_each = var.private_network != null ? [var.private_network] : []

    content {
      name = networks.value.name # required
      network = networks.value.id 
      type    = "private"   # required
      family  = networks.value.family # required
    }
  }
}

# backends

resource "upcloud_loadbalancer_backend" "main" {
  for_each = var.backends

  loadbalancer = upcloud_loadbalancer.main.id
  name         = each.key
}

locals {
  members = flatten([ for key, item in var.backends : [
    for idx, member in item : {
      idx = idx
      backend = key
      ip = member.ip
      port = member.port
      weight = member.weight
      max_sessions = member.max_sessions
      enabled = member.enabled
    }
  ]])

  members_map = { for member in local.members : "${member.backend}-${member.idx}" => member }
}

resource "upcloud_loadbalancer_static_backend_member" "main" {
  for_each = local.members_map

  backend      = upcloud_loadbalancer_backend.main[each.value.backend].id
  name         = each.key
  ip           = each.value.ip # private ip address
  port         = each.value.port
  weight       = each.value.weight
  max_sessions = each.value.max_sessions
  enabled      = each.value.enabled
}

# frontends

resource "upcloud_loadbalancer_frontend" "main" {
  for_each = var.frontends

  loadbalancer         = upcloud_loadbalancer.main.id
  name                 = each.key
  mode                 = each.value.mode
  port                 = each.value.port
  default_backend_name = upcloud_loadbalancer_backend.main[each.value.default_backend].name

  networks {
    name = upcloud_loadbalancer.main.networks[0].name # public network
  }
}

# rules

resource "upcloud_loadbalancer_frontend_rule" "main" {
  for_each = var.rules

  # required

  frontend = upcloud_loadbalancer_frontend.main[each.value.frontend].id
  name = each.key
  priority = each.value.priority
  matching_condition = each.value.matching_condition

  # optional

  dynamic actions {
    for_each = each.value.actions != null ? [each.value.actions] : []

    content {

      dynamic "http_redirect" {
        for_each = actions.value.http_redirect != null ? [actions.value.http_redirect] : []

        content {
          scheme = http_redirect.value.scheme
          location = http_redirect.value.location
        }
      }

      dynamic "http_return" {
        for_each = actions.value.http_return != null ? [actions.value.http_return] : []

        content {
          content_type = http_return.value.content_type
          payload = http_return.value.payload
          status = http_return.value.status
        }
      }

      dynamic "set_forwarded_headers" {
        for_each = actions.value.set_forwarded_headers != null ? [actions.value.set_forwarded_headers] : []

        content {
          active = set_forwarded_headers.value.active
        }
      }

      dynamic "set_request_header" {
        for_each = actions.value.set_request_header != null ? actions.value.set_request_header : []

        content {
          header = set_request_header.value.header
          value = set_request_header.value.value
        }
      }

      dynamic "set_response_header" {
        for_each = actions.value.set_response_header != null ? actions.value.set_response_header : []

        content {
          header = set_response_header.value.header
          value = set_response_header.value.value
        }
      }

      dynamic "tcp_reject" {
        for_each = actions.value.tcp_reject != null ? [actions.value.tcp_reject] : []

        content {
          active = tcp_reject.value.active
        }
      }

      dynamic "use_backend" {
        for_each = actions.value.use_backend != null ? [actions.value.use_backend] : []

        content {
          backend_name = use_backend.value.backend_name
        }
      }
    }
  }

  dynamic matchers {
    for_each = each.value.matchers != null ? [each.value.matchers] : []

    content {
      dynamic "body_size" {
        for_each = matchers.value.body_size != null ? matchers.value.body_size : []

        content {
          method = body_size.value.method
          value = body_size.value.value
          inverse = body_size.value.inverse
        }
      }

      dynamic "body_size_range" {
        for_each = matchers.value.body_size_range != null ? matchers.value.body_size_range : []

        content {
          range_end = body_size_range.value.range_end
          range_start = body_size_range.value.range_start
          inverse = body_size_range.value.inverse
        }
      }

      dynamic "cookie" {
        for_each = matchers.value.cookie != null ? matchers.value.cookie : []

        content {
          method = cookie.value.method
          name = cookie.value.name
          ignore_case = cookie.value.ignore_case
          inverse = cookie.value.inverse
          value = cookie.value.value
        }
      }

      dynamic "host" {
        for_each = matchers.value.host != null ? matchers.value.host : []

        content {
          value = host.value.value
          inverse = host.value.inverse
        }
      }

      dynamic "http_method" {
        for_each = matchers.value.http_method != null ? matchers.value.http_method : []

        content {
          value = http_method.value.value
          inverse = http_method.value.inverse
        }
      }

      dynamic "http_status" {
        for_each = matchers.value.http_status != null ? matchers.value.http_status : []

        content {
          method = http_status.value.method
          value = http_status.value.value
          inverse = http_status.value.inverse
        }
      }

      dynamic "http_status_range" {
        for_each = matchers.value.http_status_range != null ? matchers.value.http_status_range : []

        content {
          range_end = http_status_range.value.range_end
          range_start = http_status_range.value.range_start
          inverse = http_status_range.value.inverse
        }
      }

      dynamic "num_members_up" {
        for_each = matchers.value.num_members_up != null ? matchers.value.num_members_up : []

        content {
          backend_name = num_members_up.value.backend_name
          method = num_members_up.value.method
          value = num_members_up.value.value
          inverse = num_members_up.value.inverse
        }
      }

      dynamic "path" {
        for_each = matchers.value.path != null ? matchers.value.path : []

        content {
          method = path.value.method
          value = path.value.value
          ignore_case = path.value.ignore_case
          inverse = path.value.inverse
        }
      }
      
      dynamic "request_header" {
        for_each = matchers.value.request_header != null ? matchers.value.request_header : []

        content {
          method = request_header.value.method
          name = request_header.value.name
          ignore_case = request_header.value.ignore_case
          inverse = request_header.value.inverse
          value = request_header.value.value
        }
      }

      dynamic "response_header" {
        for_each = matchers.value.response_header != null ? matchers.value.response_header : []

        content {
          method = response_header.value.method
          name = response_header.value.name
          ignore_case = response_header.value.ignore_case
          inverse = response_header.value.inverse
          value = response_header.value.value
        }
      }

      dynamic "src_ip" {
        for_each = matchers.value.src_ip != null ? matchers.value.src_ip : []

        content {
          value = src_ip.value.value
          inverse = src_ip.value.inverse
        }
      }

      dynamic "src_port" {
        for_each = matchers.value.src_port != null ? matchers.value.src_port : []

        content {
          method = src_port.value.method
          value = src_port.value.value
          inverse = src_port.value.inverse
        }
      }

      dynamic "src_port_range" {
        for_each = matchers.value.src_port_range != null ? matchers.value.src_port_range : []

        content {
          range_end = src_port_range.value.range_end
          range_start = src_port_range.value.range_start
          inverse = src_port_range.value.inverse
        }
      }

      dynamic "url" {
        for_each = matchers.value.url != null ? matchers.value.url : []

        content {
          method = url.value.method
          value = url.value.value
          ignore_case = url.value.ignore_case
          inverse = url.value.inverse
        }
      }

      dynamic "url_param" {
        for_each = matchers.value.url_param != null ? matchers.value.url_param : []

        content {
          method = url_param.value.method
          name = url_param.value.name
          ignore_case = url_param.value.ignore_case
          inverse = url_param.value.inverse
          value = url_param.value.value
        }
      }

      dynamic "url_query" {
        for_each = matchers.value.url_query != null ? matchers.value.url_query : []
        content {
          method = url_query.value.method
          ignore_case = url_query.value.ignore_case
          inverse = url_query.value.inverse
          value = url_query.value.value
        }
      }
    }
  }
}