variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}
variable "env_name" {}

variable "cloudwatch_logs_delivery_full_access_policy-arn" {}

variable "sns_mlb_statsapi_event-arn" {}

variable "ecs_task_definition_mlb_statsapi_etl-arn" {}
variable "ecs_cluster_mlb_statsapi_etl-arn" {}

variable "mlb_statsapi_etl_image-repository_name" {}

variable "sf_mlb_statsapi_etl_runTask_policy-arn" {}

variable "mlb_statsapi_sg-id" {}
variable "sn_pub_a0_id" {}
variable "sn_pub_b0_id" {}

locals {
  sf_mlb_statsapi_etl_game = "mlb_statsapi_etl_game"
}


resource "aws_iam_role" "sf_mlb_statsapi_etl_game_role" {
  name = "sfn-${local.sf_mlb_statsapi_etl_game}-role-${var.aws_region}"
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


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_game_role__cloudwatch_logs_delivery_full_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.cloudwatch_logs_delivery_full_access_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_game_role.name
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_game_role__sf_mlb_statsapi_etl_game_mlb_statsapi_etl_runTask_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.sf_mlb_statsapi_etl_runTask_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_game_role.name
}



resource "aws_cloudwatch_log_group" "sf_mlb_statsapi_etl_game_logs" {
  name = "/aws/vendedlogs/states/${local.sf_mlb_statsapi_etl_game}"
  retention_in_days = 3
}


resource "aws_sfn_state_machine" "sf_mlb_statsapi_etl_game" {
  name = local.sf_mlb_statsapi_etl_game
  //noinspection HILUnresolvedReference
  role_arn = aws_iam_role.sf_mlb_statsapi_etl_game_role.arn

  definition = <<DEFINITION
{
  "Comment": "State Machine ${local.sf_mlb_statsapi_etl_game} handles the workflow for a given gamePk and gameDate.",
  "StartAt": "Game",
  "States": {
    "Game": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.waitForTaskToken",
      "ResultPath": "$.Game",
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
            "Command.$": "States.Array('python', '-u', '/app/mlb_statsapi_etl/src/mlb_statsapi/cli.py', 'Game', '--date', $.game.officialDate, '--gamePk', States.Format('{}', $.game.gamePk), '--startTime', $.game.startPregame, '--sportId', '1', '--methods', 'linescore,liveGameV1')",
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
              },
              {
                "Name": "MLB_STATSAPI__EVENT_TOPIC_ARN",
                "Value": "${var.sns_mlb_statsapi_event-arn}"
              }
            ]
          }
        ]
      }
    },
    "End": true
    }
  }
}
DEFINITION


  logging_configuration {
    //noinspection HILUnresolvedReference
    log_destination = "${aws_cloudwatch_log_group.sf_mlb_statsapi_etl_game_logs.arn}:*"
    include_execution_data = true
    level = "ERROR"
  }
  depends_on = [
    aws_iam_role.sf_mlb_statsapi_etl_game_role,
    aws_iam_role_policy_attachment.sf_mlb_statsapi_etl_game_role__cloudwatch_logs_delivery_full_access_policy,
    aws_cloudwatch_log_group.sf_mlb_statsapi_etl_game_logs
  ]
}


output "sf_mlb_statsapi_etl_game-arn" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_game.arn
}

output "sf_mlb_statsapi_etl_game-name" {
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_game.name
}
