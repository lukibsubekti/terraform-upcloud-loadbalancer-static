variable "zone" {
  type = string
  description = "UpCloud zone"
}

variable "public_network" {
  type = object({
    name: optional(string, "public-net")
    family: optional(string, "IPv4")
  })
  description = "Public network to attach the load balancer to"
  default = null
}

variable "private_network" {
  type = object({
    id: string
    name: string
    family: optional(string, "IPv4")
  })
  description = "Private network to attach the load balancer to"
  default = null
}

variable "name" {
  type = string
  description = "Name of the load balancer"
  default = "main"
}

variable "plan" {
  type = string
  description = "Load balancer plan"
  default = "development"
  validation {
    condition = contains(local.loadbalancer_plans , var.plan)
    error_message = "Invalid load balancer plan"
  }
}

variable "backends" {
  type = map(list(object({
    ip: string
    port: number
    weight: optional(number, 100)
    max_sessions: optional(number, 1000)
    enabled: optional(bool, true)
  })))
  description = "Load balancer backends"
  default = {}
}

variable "frontends" {
  type = map(object({
    mode: string
    port: number
    default_backend: string
  }))
  description = "Load balancer frontends"
  default = {}
}

variable "rules" {
  type = map(object({
    frontend: string
    priority: number
    matching_condition: optional(string, "and")

    actions: optional(object({
      http_redirect: optional(object({
        location: optional(string, null)
        scheme: optional(string, null)
      }), null)

      http_return: optional(object({
        content_type: string
        payload: string
        status: number
      }), null)

      set_forwarded_headers: optional(object({
        active: optional(bool, true)
      }), null)

      set_request_header: optional(list(object({
        header: string
        value: optional(string, null)
      })), null)

      set_response_header: optional(list(object({
        header: string
        value: optional(string, null)
      })), null)

      tcp_reject: optional(object({
        active: optional(bool, true)
      }), null)

      use_backend: optional(object({
        backend_name: string
      }), null)
    }), null)

    matchers: optional(object({
      body_size: optional(list(object({
        # method: equal, greater, greater_or_equal, less, less_or_equal
        method: string
        value: number
        inverse: optional(bool, false)
      })), null)

      body_size_range: optional(list(object({
        range_end: number
        range_start: number
        inverse: optional(bool, false)
      })), null)

      cookie: optional(list(object({
        # method: exact, substring, regexp, starts, ends, domain, ip, exists
        method: string
        name: string
        ignore_case: optional(bool, false)
        inverse: optional(bool, false)
        value: optional(string, null)
      })), null)

      host: optional(list(object({
        value: string
        inverse: optional(bool, false)
      })), null)

      http_method: optional(list(object({
        # value: GET, HEAD, POST, PUT, PATCH, DELETE, CONNECT, OPTIONS, TRACE
        value: string
        inverse: optional(bool, false)
      })), null)

      http_status: optional(list(object({
        # method: equal, greater, greater_or_equal, less, less_or_equal
        method: string
        value: number
        inverse: optional(bool, false)
      })), null)

      http_status_range: optional(list(object({
        range_end: number
        range_start: number
        inverse: optional(bool, false)
      })), null)

      num_members_up: optional(list(object({
        backend_name: string
        # method: equal, greater, greater_or_equal, less, less_or_equal
        method: string
        value: number
        inverse: optional(bool, false)
      })), null)

      path: optional(list(object({
        # method: exact, substring, regexp, starts, ends, domain, ip, exists
        method: string
        ignore_case: optional(bool, false)
        inverse: optional(bool, false)
        value: optional(string, null)
      })), null)

      request_header: optional(list(object({
        # method: exact, substring, regexp, starts, ends, domain, ip, exists
        method: string
        name: string
        ignore_case: optional(bool, false)
        inverse: optional(bool, false)
        value: optional(string, null)
      })), null)

      response_header: optional(list(object({
        # method: exact, substring, regexp, starts, ends, domain, ip, exists
        method: string
        name: string
        ignore_case: optional(bool, false)
        inverse: optional(bool, false)
        value: optional(string, null)
      })), null)

      src_ip: optional(list(object({
        # value: IP address or CIDR block
        value: string
        inverse: optional(bool, false)
      })), null)

      src_port: optional(list(object({
        # method: equal, greater, greater_or_equal, less, less_or_equal
        method: string
        value: number
        inverse: optional(bool, false)
      })), null)

      src_port_range: optional(list(object({
        range_end: number
        range_start: number
        inverse: optional(bool, false)
      })), null)

      url: optional(list(object({
        # method: exact, substring, regexp, starts, ends, domain, ip, exists
        method: string
        ignore_case: optional(bool, false)
        inverse: optional(bool, false)
        value: optional(string, null)
      })), null)

      url_param: optional(list(object({
        # method: exact, substring, regexp, starts, ends, domain, ip, exists
        method: string
        name: string
        ignore_case: optional(bool, false)
        inverse: optional(bool, false)
        value: optional(string, null)
      })), null)

      url_query: optional(list(object({
        # method: exact, substring, regexp, starts, ends, domain, ip, exists
        method: string
        ignore_case: optional(bool, false)
        inverse: optional(bool, false)
        value: optional(string, null)
      })), null)

    }), null)
  }))
  description = "Load balancer frontend rules"
  default = {}
}
