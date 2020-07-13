resource "consul_keys" "web" {
  for_each = var.services

  key {
    path  = "${var.workspace}/${each.value.name}"
    value = each.value.address
    delete = true
  }
}
