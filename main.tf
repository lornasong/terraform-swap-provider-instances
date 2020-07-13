terraform {
    required_version = ">=0.12"
}

provider "consul" {
  address = var.provider_address
  datacenter = var.provider_datacenter
}

module "consul" {
  source = "./modules/consul"
  services = var.services
  workspace = var.workspace
}
