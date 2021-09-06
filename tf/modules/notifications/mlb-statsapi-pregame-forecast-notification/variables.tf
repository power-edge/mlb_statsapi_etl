variable "aws_region" {}
variable "env_name" {}
locals {
  name = "${var.env_name}-pregame-forecast"
}
