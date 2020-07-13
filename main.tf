terraform {
    required_version = ">=0.12"
}

locals {
  consul_provider_settings = tomap ({
    east = {
      address = "localhost:8500"
      datacenter = "dc1"
    }
    west = {
      address = "localhost:8501"
      datacenter = "dc1"
    }
  })
}

provider "consul" {
  address = local.consul_provider_settings[var.workspace].address
  datacenter = local.consul_provider_settings[var.workspace].datacenter
}

module "consul" {
  source = "./modules/consul"
  services = { for name in var.service_mapping[var.workspace] : name => var.services[name]}
  workspace = var.workspace
}
