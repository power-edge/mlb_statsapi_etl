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


resource "aws_iam_role" "sf_mlb_statsapi_etl_gameday_role" {
  name = "sfn-${local.sf_mlb_statsapi_etl_gameday}-role-${var.aws_region}"
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


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__cloudwatch_logs_delivery_full_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.cloudwatch_logs_delivery_full_access_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_gameday_role.name
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__mlb_statsapi_sns_publish_workflow_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.mlb_statsapi_sns_publish_workflow_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_gameday_role.name
}


resource "aws_iam_policy" "gameday_invoke_lambda_scoped_access_policy" {
  name = "gameday_invoke_lambda_scoped_access_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          var.mlb_statsapi_states_gameday_date_in_season_lambda-arn,
          var.mlb_statsapi_states_gameday_set_scheduled_games_lambda-arn,
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__gameday_invoke_lambda_scoped_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.gameday_invoke_lambda_scoped_access_policy.arn
  role = aws_iam_role.sf_mlb_statsapi_etl_gameday_role.name
}


resource "aws_cloudwatch_log_group" "sf_mlb_statsapi_etl_gameday_logs" {
  name = "/aws/vendedlogs/states/${local.sf_mlb_statsapi_etl_gameday}"
  retention_in_days = 3
}


resource "aws_sfn_state_machine" "sf_mlb_statsapi_etl_gameday" {
  name = local.sf_mlb_statsapi_etl_gameday
  role_arn = aws_iam_role.sf_mlb_statsapi_etl_gameday_role.arn

  definition = <<DEFINITION
{
  "Comment": "State Machine ${local.sf_mlb_statsapi_etl_gameday} handles the schedule and game workflow of gameday.",
  "StartAt": "date_in_season",
  "States": {
    "date_in_season": {
      "Type": "Task",
      "Resource": "${var.mlb_statsapi_states_gameday_date_in_season_lambda-arn}",
      "Parameters": {
        "date.$": "$.date"
      },
      "ResultPath": "$.date_in_season",
      "Next": "in_or_off_season_choice"
    },
    "in_or_off_season_choice": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.date_in_season",
          "BooleanEquals": false,
          "Next": "off_season"
        },
        {
          "Variable": "$.date_in_season",
          "BooleanEquals": true,
          "Next": "set_scheduled_games"
        }
      ]
    },
    "off_season": {
      "Type": "Pass",
      "End": true
    },
    "set_scheduled_games": {
      "Type": "Task",
      "Resource": "${var.mlb_statsapi_states_gameday_set_scheduled_games_lambda-arn}",
      "Parameters": {
        "date.$": "$.date"
      },
      "ResultPath": "$.scheduled_games",
      "Next": "notify_workflows_for_schedule_and_pregame"
    },
    "notify_workflows_for_schedule_and_pregame": {
      "Type": "Parallel",
      "End": true,
      "Branches": [
        {
          "StartAt": "wait-until-first-pregame",
          "States": {
            "wait-until-first-pregame": {
              "Type": "Wait",
              "TimestampPath": "$.scheduled_games.firstPregame",
              "Next": "schedule-workflow-notification"
            },
            "schedule-workflow-notification": {
              "Type": "Task",
              "Resource": "arn:aws:states:::sns:publish",
              "Parameters": {
                "TopicArn": "${var.sns_mlb_statsapi_workflow-arn}",
                "Message.$": "States.JsonToString($.schedule.message)",
                "MessageAttributes": {
                  "Sport": {
                    "DataType": "String",
                    "StringValue": "MLB"
                  }
                }
              },
              "End": true
            }
          }
        },
        {
          "StartAt": "gamePks",
          "States": {
            "gamePks": {
              "Type": "Map",
              "ItemsPath": "$.scheduled_games.games",
              "Parameters": {
                "date.$": "$.date",
                "game.$": "$$.Map.Item.Value"
              },
              "Iterator": {
                "StartAt": "wait-until-pregame",
                "States": {
                  "wait-until-pregame": {
                    "Type": "Wait",
                    "TimestampPath": "$.game.startPregame",
                    "Next": "pregame-workflow-notification"
                  },
                  "pregame-workflow-notification": {
                    "Type": "Task",
                    "Resource": "arn:aws:states:::sns:publish",
                    "Parameters": {
                      "TopicArn": "${var.sns_mlb_statsapi_workflow-arn}",
                      "Message.$": "States.JsonToString($.game)",
                      "MessageAttributes": {
                        "Sport": {
                          "DataType": "String",
                          "StringValue": "MLB"
                        }
                      }
                    },
                    "End": true
                  }
                }
              },
              "ResultPath": "$.gamePks",
              "End": true
            }
          }
        }
      ]
    }
  }
}
DEFINITION


  logging_configuration {
    //noinspection HILUnresolvedReference
    log_destination = "${aws_cloudwatch_log_group.sf_mlb_statsapi_etl_gameday_logs.arn}:*"
    include_execution_data = true
    level = "ERROR"
  }
  depends_on = [
    aws_iam_role.sf_mlb_statsapi_etl_gameday_role,
    aws_iam_role_policy_attachment.sf_mlb_statsapi_etl_gameday_role__cloudwatch_logs_delivery_full_access_policy,
    aws_iam_policy.gameday_invoke_lambda_scoped_access_policy,
    aws_iam_role_policy_attachment.sf_mlb_statsapi_etl_gameday_role__gameday_invoke_lambda_scoped_access_policy,
    aws_cloudwatch_log_group.sf_mlb_statsapi_etl_gameday_logs
  ]
}


output "sf_mlb_statsapi_etl_gameday" {
  value = local.sf_mlb_statsapi_etl_gameday
}

output "sf_mlb_statsapi_etl_gameday-arn" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_gameday.arn
}

output "sf_mlb_statsapi_etl_gameday-name" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_gameday.name
}