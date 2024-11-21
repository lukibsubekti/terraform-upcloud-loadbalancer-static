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

output "frontends" {
  value = [ for frontend in upcloud_loadbalancer_frontend.main : {
    id = frontend.id
    name = frontend.name
  } ]
}

output "rules" {
  value = [ for rule in upcloud_loadbalancer_frontend_rule.main : {
    id = rule.id
    name = rule.name
    frontend = rule.frontend
  } ]
  description = "List of load balancer rules"
}