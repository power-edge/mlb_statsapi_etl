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
      "Next": "wait_until_first_pregame"
    },
    "wait_until_first_pregame": {
      "Type": "Wait",
      "TimestampPath": "$.scheduled_games.firstPregame",
      "Next": "schedule_workflow_notification"
    },
    "schedule_workflow_notification": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "ResultPath": "$.schedule_workflow_notification",
      "Parameters": {
        "TopicArn": "${var.sns_mlb_statsapi_workflow-arn}",
        "Message.$": "States.JsonToString($.schedule.message)",
        "MessageAttributes": {
          "League": {
            "DataType": "String",
            "StringValue": "MLB"
          }
        }
      },
      "Next": "gamePks"
    },
    "gamePks": {
      "Type": "Map",
      "ItemsPath": "$.scheduled_games.games",
      "Parameters": {
        "date.$": "$.date",
        "game.$": "$$.Map.Item.Value"
      },
      "ResultPath": "$.gamePks",
      "Iterator": {
        "StartAt": "wait_until_pregame",
        "States": {
          "wait_until_pregame": {
            "Type": "Wait",
            "TimestampPath": "$.game.startPregame",
            "Next": "pregame_workflow_notification"
          },
          "pregame_workflow_notification": {
            "Type": "Task",
            "Resource": "arn:aws:states:::sns:publish",
            "ResultPath": "$.pregame_workflow_notification",
            "Parameters": {
              "TopicArn": "${var.sns_mlb_statsapi_workflow-arn}",
              "Message.$": "States.JsonToString($.game)",
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
      },
      "End": true
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