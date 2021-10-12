resource "aws_cloudwatch_log_group" "sf_mlb_statsapi_etl_pregame_logs" {
  name = "/aws/vendedlogs/states/${local.sf_mlb_statsapi_etl_pregame}"
  retention_in_days = 3
}


resource "aws_sfn_state_machine" "sf_mlb_statsapi_etl_pregame" {
  name = local.sf_mlb_statsapi_etl_pregame
  //noinspection HILUnresolvedReference
  role_arn = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.arn

  definition = <<DEFINITION
{
  "Comment": "State Machine ${local.sf_mlb_statsapi_etl_pregame} handles the workflow for a give pregame and gameDate.",
  "StartAt": "set_game",
  "States": {
    "set_game": {
      "Type": "Task",
      "Resource": "${var.mlb_statsapi_states_pregame_set_game_lambda-arn}",
      "Parameters": {
        "game.$": "$.game"
      },
      "ResultPath": "$.set_game",
      "Next": "pregame_forecast_notification"
    },
    "pregame_forecast_notification": {
      "Type": "Task",
      "ResultPath": "$.pregame_forecast_notification",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${var.sns_mlb_statsapi_pregame_forecast-arn}",
        "Message.$": "States.JsonToString($.set_game.Forecast)",
        "MessageAttributes": {
          "League": {
            "DataType": "String",
            "StringValue": "mlb"
          },
          "Workflow": {
            "DataType": "String",
            "StringValue": "${var.sf_mlb_statsapi_etl_game-arn}"
          },
          "Env": {
            "DataType": "String",
            "StringValue": "${var.env_name}"
          }
        }
      },
      "Next": "Team"
    },
    "Team": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.waitForTaskToken",
      "ResultPath": "$.Team",
      "TimeoutSeconds": 180,
      "Parameters": {
        "Cluster": "${var.ecs_cluster_mlb_statsapi_etl-arn}",
        "Group": "${var.mlb_statsapi_etl_image-repository_name}",
        "LaunchType": "FARGATE",
        "TaskDefinition": "${var.ecs_task_definition_mlb_statsapi_etl-arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "ENABLED",
            "SecurityGroups": [
              "${var.mlb_statsapi_sg-id}"
            ],
            "Subnets": ${jsonencode(var.subnet_public_ids)}
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "${var.mlb_statsapi_etl_image-repository_name}",
              "Cpu": 256,
              "Memory": 512,
              "MemoryReservation": 256,
              "Command.$": "States.Array('python', '-u', '/app/mlb_statsapi_etl/src/mlb_statsapi/cli.py', '--force=false', 'Team', '-m=roster', States.Format('-d={}', $.game.officialDate), States.Format('-rt={}', $.set_game.Team.rosterType), '--teamIdsJSON', States.JsonToString($.game.teams..team.id))",
              "Environment": [
                {
                  "Name": "AWS_STEP_FUNCTIONS_EXECUTION_ID",
                  "Value.$": "$$.Execution.Id"
                },
                {
                  "Name": "AWS_STEP_FUNCTIONS_TASK_TOKEN",
                  "Value.$": "$$.Task.Token"
                },
                {
                  "Name": "MLB_STATSAPI__ENV",
                  "Value": "${var.env_name}"
                },
                {
                  "Name": "MLB_STATSAPI__REGION",
                  "Value": "${var.aws_region}"
                },
                {
                  "Name": "MLB_STATSAPI__S3_DATA_BUCKET",
                  "Value": "${var.mlb_statsapi_s3_data_bucket}"
                }
              ]
            }
          ]
        }
      },
      "Next": "Person"
    },
    "Person": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.waitForTaskToken",
      "ResultPath": "$.Person",
      "TimeoutSeconds": 180,
      "Parameters": {
        "Cluster": "${var.ecs_cluster_mlb_statsapi_etl-arn}",
        "Group": "${var.mlb_statsapi_etl_image-repository_name}",
        "LaunchType": "FARGATE",
        "TaskDefinition": "${var.ecs_task_definition_mlb_statsapi_etl-arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "ENABLED",
            "SecurityGroups": [
              "${var.mlb_statsapi_sg-id}"
            ],
            "Subnets": ${jsonencode(var.subnet_public_ids)}
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "${var.mlb_statsapi_etl_image-repository_name}",
              "Cpu": 256,
              "Memory": 512,
              "MemoryReservation": 256,
              "Command.$": "States.Array('python', '-u', '/app/mlb_statsapi_etl/src/mlb_statsapi/cli.py', '--force=false', 'Person', '-m=person', States.Format('--season={}', $.game.season), '--personIdsJSON', States.JsonToString($.Team.personIds), States.JsonToString($.set_game.Official.officials..official.id))",
              "Environment": [
                {
                  "Name": "AWS_STEP_FUNCTIONS_EXECUTION_ID",
                  "Value.$": "$$.Execution.Id"
                },
                {
                  "Name": "AWS_STEP_FUNCTIONS_TASK_TOKEN",
                  "Value.$": "$$.Task.Token"
                },
                {
                  "Name": "MLB_STATSAPI__ENV",
                  "Value": "${var.env_name}"
                },
                {
                  "Name": "MLB_STATSAPI__REGION",
                  "Value": "${var.aws_region}"
                },
                {
                  "Name": "MLB_STATSAPI__S3_DATA_BUCKET",
                  "Value": "${var.mlb_statsapi_s3_data_bucket}"
                }
              ]
            }
          ]
        }
      },
      "Next": "game_workflow_notification"
    },
    "game_workflow_notification": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "ResultPath": "$.game_workflow_notification",
      "Parameters": {
        "TopicArn": "${var.sns_mlb_statsapi_workflow-arn}",
        "Message.$": "States.JsonToString($.game)",
        "MessageAttributes": {
          "League": {
            "DataType": "String",
            "StringValue": "MLB"
          },
          "Workflow": {
            "DataType": "String",
            "StringValue": "${var.sf_mlb_statsapi_etl_game-arn}"
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
    log_destination = "${aws_cloudwatch_log_group.sf_mlb_statsapi_etl_pregame_logs.arn}:*"
    include_execution_data = true
    level = "ERROR"
  }
  depends_on = [
    aws_iam_role.sf_mlb_statsapi_etl_pregame_role,
    aws_iam_role_policy_attachment.sf_mlb_statsapi_etl_pregame_role__cloudwatch_logs_delivery_full_access_policy,
    aws_cloudwatch_log_group.sf_mlb_statsapi_etl_pregame_logs
  ]
}
