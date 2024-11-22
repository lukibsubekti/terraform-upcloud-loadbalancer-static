# output "members" {
#   value = local.members
#   description = "List of load balancer backend members"
# }

output "id" {
  value = upcloud_loadbalancer.main.id
  description = "Load balancer ID"
}

output "backends" {
  value = [ for backend in upcloud_loadbalancer_backend.main : {
    id = backend.id
    name = backend.name
  } ]
  description = "List of load balancer backends"
}

output "backends_map" {
  value = { for backend in upcloud_loadbalancer_backend.main : backend.name => {
    id = backend.id
    name = backend.name
  } }
  description = "Map of load balancer backends"
}

output "frontends" {
  value = [ for frontend in upcloud_loadbalancer_frontend.main : {
    id = frontend.id
    name = frontend.name
  } ]
}

output "frontends_map" {
  value = { for frontend in upcloud_loadbalancer_frontend.main : frontend.name => {
    id = frontend.id
    name = frontend.name
  } }
}

output "rules" {
  value = [ for rule in upcloud_loadbalancer_frontend_rule.main : {
    id = rule.id
    name = rule.name
    frontend = rule.frontend
  } ]
  description = "List of load balancer rules"
}

output "networks" {
  value = upcloud_loadbalancer.main.networks
  description = "Load balancer networks"
}

output "networks_map" {
  value = { for network in upcloud_loadbalancer.main.networks : network.name => {
    id = network.id
    name = network.name
    dns_name = network.dns_name
    family = network.family
    type = network.type
    network = network.network
  } }
}