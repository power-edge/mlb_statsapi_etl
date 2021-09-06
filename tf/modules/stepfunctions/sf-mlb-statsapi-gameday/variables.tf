variable "env_name" {}
variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}

variable "mlb_statsapi_states_gameday_date_in_season_lambda-function_name" {}
variable "mlb_statsapi_states_gameday_date_in_season_lambda-arn" {}

variable "mlb_statsapi_states_gameday_set_scheduled_games_lambda-function_name" {}
variable "mlb_statsapi_states_gameday_set_scheduled_games_lambda-arn" {}

variable "cloudwatch_logs_delivery_full_access_policy-arn" {}

variable "sns_mlb_statsapi_workflow-arn" {}
variable "mlb_statsapi_sns_publish_workflow_policy-arn" {}

//variable "sf_mlb_statsapi_etl_gamePk-arn" {}
//variable "sf_mlb_statsapi_etl_gamePk-name" {}


locals {
  sf_mlb_statsapi_etl_gameday = "mlb_statsapi_etl_gameday"
}
