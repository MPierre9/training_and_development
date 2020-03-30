terraform {
  required_version = "0.12.24"
}

module "consul" {
  source      = "hashicorp/consul/aws"
  num_servers = "3"
}


output "consul_server_asg_name" {
  value = "${module.consul.asg_name_servers}"
}