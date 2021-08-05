variable "build" {
    type = string
    default = "latest"
}

locals {
  build = var.build
}

output "build" {
  value = local.build
}
