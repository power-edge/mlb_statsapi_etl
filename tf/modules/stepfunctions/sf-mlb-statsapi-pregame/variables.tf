variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}
variable "env_name" {}

variable "cloudwatch_logs_delivery_full_access_policy-arn" {}
variable "iam_policy_snsPublish_pregame_forecast-arn" {}

variable "sns_mlb_statsapi_event-arn" {}
variable "sns_mlb_statsapi_workflow-arn" {}
variable "sns_mlb_statsapi_pregame_forecast-arn" {}

variable "mlb_statsapi_s3_data_bucket" {}
variable "sn_pub_a0_id" {}
variable "sn_pub_b0_id" {}

variable "mlb_statsapi_etl_image-repository_name" {}
variable "ecs_task_definition_mlb_statsapi_etl-arn" {}
variable "ecs_cluster_mlb_statsapi_etl-arn" {}

variable "mlb_statsapi_sns_publish_event_policy-arn" {}
variable "mlb_statsapi_sns_publish_workflow_policy-arn" {}
variable "mlb_statsapi_states_pregame_set_game_lambda-arn" {}

variable "sf_mlb_statsapi_etl_game-arn" {}
variable "sf_mlb_statsapi_etl_runTask_policy-arn" {}
variable "mlb_statsapi_sg-id" {}

locals {
  sf_mlb_statsapi_etl_pregame = "mlb_statsapi_etl_pregame"
}
