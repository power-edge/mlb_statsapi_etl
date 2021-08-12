variable "env_name" {}
variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}

variable "mlb_statsapi_states_gameday_date_in_season_lambda-function_name" {}
variable "mlb_statsapi_states_gameday_date_in_season_lambda-arn" {}

variable "mlb_statsapi_states_gameday_set_scheduled_games_lambda-function_name" {}
variable "mlb_statsapi_states_gameday_set_scheduled_games_lambda-arn" {}

variable "cloudwatch_logs_delivery_full_access_policy-arn" {}

variable "sf_mlb_statsapi_etl_gamePk-arn" {}
variable "sf_mlb_statsapi_etl_gamePk-name" {}

variable "mlb_statsapi_etl_image-repository_name" {}
variable "ecs_cluster_mlb_statsapi_etl-arn" {}
variable "ecs_task_definition_mlb_statsapi_etl-arn" {}

variable "ecs_mlb_statsapi_etl-taskExecutionRole-arn" {}
variable "ecs_mlb_statsapi_etl-taskRole-arn" {}

variable "mlb_statsapi_sg-id" {}
variable "sn_pub_a0_id" {}
variable "sn_pub_b0_id" {}


locals {
  sf_mlb_statsapi_etl_gameday = "mlb_statsapi_etl_gameday"
}


resource "aws_iam_role" "sf_mlb_statsapi_etl_gameday_role" {
  name = "${local.sf_mlb_statsapi_etl_gameday}-role-${var.aws_region}"
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


resource "aws_iam_policy" "sf_mlb_statsapi_etl_gameday_synchronous_gamePk_start_execution_policy" {
  name = "tf_sf_mlb_statsapi_etl_gameday_synchronous_gamePk_start_execution_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = [
          "arn:aws:states:${var.aws_region}:${var.aws_account}:stateMachine:${var.sf_mlb_statsapi_etl_gamePk-name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "states:DescribeExecution",
          "states:StopExecution"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule"
        ]
        Resource = "arn:aws:events:${var.aws_region}:${var.aws_account}:rule/StepFunctionsGetEventsForStepFunctionsExecutionRule"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__sf_mlb_statsapi_etl_gameday_synchronous_gamePk_start_execution_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.sf_mlb_statsapi_etl_gameday_synchronous_gamePk_start_execution_policy.arn
  role = aws_iam_role.sf_mlb_statsapi_etl_gameday_role.name
}


resource "aws_iam_policy" "sf_mlb_statsapi_etl_gameday_mlb_statsapi_etl_runTask_policy" {
  name = "sf_mlb_statsapi_etl_gameday_mlb_statsapi_etl_runTask_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "ecs:RunTask"
        Resource = var.ecs_task_definition_mlb_statsapi_etl-arn
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          var.ecs_mlb_statsapi_etl-taskRole-arn,
          var.ecs_mlb_statsapi_etl-taskExecutionRole-arn
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__sf_mlb_statsapi_etl_gameday_mlb_statsapi_etl_runTask_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.sf_mlb_statsapi_etl_gameday_mlb_statsapi_etl_runTask_policy.arn
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
//          "arn:aws:lambda:${var.aws_region}:${var.aws_account}:function:${var.mlb_statsapi_states_gameday_date_in_season_lambda-function_name}",
//          "arn:aws:lambda:${var.aws_region}:${var.aws_account}:function:${var.mlb_statsapi_states_gameday_set_scheduled_games_lambda-function_name}",
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
      "ResultPath": "$.games",
      "Next": "runSchedule_and_gamePks_in_parallel"
    },
    "runSchedule_and_gamePks_in_parallel": {
      "Type": "Parallel",
      "End": true,
      "Branches": [
        {
          "StartAt": "runSchedule",
          "States": {
            "runSchedule": {
              "Type": "Task",
              "Resource": "arn:aws:states:::ecs:runTask.waitForTaskToken",
              "ResultPath": "$.runSchedule",
              "TimeoutSeconds": 86400,
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
                  "Subnets": [
                    "${var.sn_pub_a0_id}",
                    "${var.sn_pub_b0_id}"
                  ]
                }
              },
              "Overrides": {
                "ContainerOverrides": [
                  {
                    "Name": "${var.mlb_statsapi_etl_image-repository_name}",
                    "Command.$": "States.Array('python', '/app/mlb_statsapi_etl/src/mlb_statsapi/cli.py', '--indent=0', 'Schedule', '--date', $.date)",
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
                        "Name": "AWS_REGION",
                        "Value": "${var.aws_region}"
                      }
                    ]
                  }
                ]
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
              "ItemsPath": "$.games",
              "Parameters": {
                "date.$": "$.date",
                "game.$": "$$.Map.Item.Value"
              },
              "Iterator": {
                "StartAt": "waitUntil",
                "States": {
                  "waitUntil": {
                    "Type": "Wait",
                    "TimestampPath": "$.game.waitUntil",
                    "Next": "${var.sf_mlb_statsapi_etl_gamePk-name}"
                  },
                  "${var.sf_mlb_statsapi_etl_gamePk-name}": {
                    "Type": "Task",
                    "Resource": "arn:aws:states:::states:startExecution.sync",
                    "Parameters": {
                      "Name.$": "States.Format('{}-{}-{}', $.game.gamePk, $.game.startTimestamp, $.game.uid)",
                      "StateMachineArn": "${var.sf_mlb_statsapi_etl_gamePk-arn}",
                      "Input": {
                        "date.$": "$.date",
                        "game.$": "$.game",
                        "AWS_STEP_FUNCTIONS_STARTED_BY_EXECUTION_ID.$": "$$.Execution.Id",
                        "AWS_STEP_FUNCTIONS_TASK_TOKEN.$": "$$.Task.Token"
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
    aws_iam_policy.sf_mlb_statsapi_etl_gameday_synchronous_gamePk_start_execution_policy,
    aws_iam_role_policy_attachment.sf_mlb_statsapi_etl_gameday_role__sf_mlb_statsapi_etl_gameday_synchronous_gamePk_start_execution_policy,
    aws_iam_policy.gameday_invoke_lambda_scoped_access_policy,
    aws_iam_role_policy_attachment.sf_mlb_statsapi_etl_gameday_role__gameday_invoke_lambda_scoped_access_policy,
    aws_cloudwatch_log_group.sf_mlb_statsapi_etl_gameday_logs
  ]
}

output "sf_mlb_statsapi_etl_gameday-arn" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_gameday.arn
}