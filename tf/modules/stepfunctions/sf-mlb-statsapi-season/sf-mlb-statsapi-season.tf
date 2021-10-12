variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}
variable "env_name" {}

variable "cloudwatch_logs_delivery_full_access_policy-arn" {}
variable "sns_mlb_statsapi_event-arn" {}

variable "mlb_statsapi_sns_publish_event_policy-arn" {}

locals {
  sf_mlb_statsapi_etl_season = "mlb_statsapi_etl_season"
}


resource "aws_iam_role" "sf_mlb_statsapi_etl_season_role" {
  name = "sfn-${local.sf_mlb_statsapi_etl_season}-role-${var.aws_region}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_season_role__cloudwatch_logs_delivery_full_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.cloudwatch_logs_delivery_full_access_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_season_role.name
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_season_role__mlb_statsapi_sns_publish_event_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.mlb_statsapi_sns_publish_event_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_season_role.name
}


resource "aws_cloudwatch_log_group" "sf_mlb_statsapi_etl_season_logs" {
  name = "/aws/vendedlogs/states/${local.sf_mlb_statsapi_etl_season}"
  retention_in_days = 3
}


resource "aws_sfn_state_machine" "sf_mlb_statsapi_etl_season" {
  name = local.sf_mlb_statsapi_etl_season
  //noinspection HILUnresolvedReference
  role_arn = aws_iam_role.sf_mlb_statsapi_etl_season_role.arn

  definition = <<DEFINITION
{
  "Comment": "State Machine ${local.sf_mlb_statsapi_etl_season} handles the workflow for a give season and gameDate.",
  "StartAt": "season-notification",
  "States": {
    "season-notification": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${var.sns_mlb_statsapi_event-arn}",
        "Message.$": "States.JsonToString($.season.message)",
        "MessageAttributes": {
          "League": {
            "DataType": "String",
            "StringValue": "MLB"
          }
        }
      },
      "End": true
    }
  }
}
DEFINITION

  logging_configuration {
    //noinspection HILUnresolvedReference
    log_destination = "${aws_cloudwatch_log_group.sf_mlb_statsapi_etl_season_logs.arn}:*"
    include_execution_data = true
    level = "ERROR"
  }
  depends_on = [
    aws_iam_role.sf_mlb_statsapi_etl_season_role,
    aws_iam_role_policy_attachment.sf_mlb_statsapi_etl_season_role__cloudwatch_logs_delivery_full_access_policy,
    aws_cloudwatch_log_group.sf_mlb_statsapi_etl_season_logs
  ]
}


output "sf_mlb_statsapi_etl_season-arn" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_season.arn
}

output "sf_mlb_statsapi_etl_season-name" {
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_season.name
}
