variable "services" {
  description = "Services that an instance needs to care about"
  type = map(object({
    # Name of the service
    name = string
    # List of addresses for instances of the service
    address = string
  }))
}

variable "workspace" {
  description = "workspace name"
  type = string
  default = ""
}

variable "provider_address" {
  description = "provider instance's address"
  type = string
  default = ""
}

variable "provider_datacenter" {
  description = "provider instance's datacenter"
  type = string
  default = "dc1"
}
