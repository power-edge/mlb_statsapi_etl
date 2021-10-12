variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}
variable "env_name" {}

variable "cloudwatch_logs_delivery_full_access_policy-arn" {}

variable "mlb_statsapi_s3_data_bucket" {}

variable "ecs_task_definition_mlb_statsapi_etl-arn" {}
variable "ecs_cluster_mlb_statsapi_etl-arn" {}

variable "mlb_statsapi_etl_image-repository_name" {}

variable "sf_mlb_statsapi_etl_runTask_policy-arn" {}

variable "mlb_statsapi_sg-id" {}
variable "subnet_public_ids" {}


locals {
  sf_mlb_statsapi_etl_game = "mlb_statsapi_etl_game"
}
