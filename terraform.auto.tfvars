service_mapping = {
  west = ["web2", "web1"]
  east = ["web1"]
}

services = {
  web1: {
    name = "web1"
    address = "192.0.0.1:8500"
  },
  web2: {
    name = "web2"
    address = "10.10.10.10:8000"
  }
}
