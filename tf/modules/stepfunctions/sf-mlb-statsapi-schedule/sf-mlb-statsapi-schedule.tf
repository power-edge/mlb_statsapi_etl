variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}
variable "env_name" {}

variable "cloudwatch_logs_delivery_full_access_policy-arn" {}

variable "mlb_statsapi_sg-id" {}
variable "sn_pub_b0_id" {}
variable "sn_pub_a0_id" {}

variable "mlb_statsapi_etl_image-repository_name" {}
variable "ecs_task_definition_mlb_statsapi_etl-arn" {}
variable "ecs_cluster_mlb_statsapi_etl-arn" {}
variable "ecs_mlb_statsapi_etl-taskRole-arn" {}
variable "ecs_mlb_statsapi_etl-taskExecutionRole-arn" {}
variable "sf_mlb_statsapi_etl_runTask_policy-arn" {}


locals {
  sf_mlb_statsapi_etl_schedule = "mlb_statsapi_etl_schedule"
}


resource "aws_iam_role" "sf_mlb_statsapi_etl_schedule_role" {
  name = "sfn-${local.sf_mlb_statsapi_etl_schedule}-role-${var.aws_region}"
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

resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_schedule_role__cloudwatch_logs_delivery_full_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.cloudwatch_logs_delivery_full_access_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_schedule_role.name
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_schedule_role__sf_mlb_statsapi_etl_runTask_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.sf_mlb_statsapi_etl_runTask_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_schedule_role.name
}


resource "aws_cloudwatch_log_group" "sf_mlb_statsapi_etl_schedule_logs" {
  name = "/aws/vendedlogs/states/${local.sf_mlb_statsapi_etl_schedule}"
  retention_in_days = 3
}


resource "aws_sfn_state_machine" "sf_mlb_statsapi_etl_schedule" {
  name = local.sf_mlb_statsapi_etl_schedule
  //noinspection HILUnresolvedReference
  role_arn = aws_iam_role.sf_mlb_statsapi_etl_schedule_role.arn

  definition = <<DEFINITION
{
  "Comment": "State Machine ${local.sf_mlb_statsapi_etl_schedule} handles the workflow for a give schedule and gameDate.",
  "StartAt": "Schedule",
  "States": {
    "Schedule": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.waitForTaskToken",
      "ResultPath": "$.Schedule",
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
            "Command.$": "States.Array('python', '-u', '/app/mlb_statsapi_etl/src/mlb_statsapi/cli.py', 'Schedule', States.Format('--date={}', $.date), '-m=schedule')",
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
                "Name": "MLB_STATSAPI__REGION",
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
}
DEFINITION

  logging_configuration {
    //noinspection HILUnresolvedReference
    log_destination = "${aws_cloudwatch_log_group.sf_mlb_statsapi_etl_schedule_logs.arn}:*"
    include_execution_data = true
    level = "ERROR"
  }
  depends_on = [
    aws_iam_role.sf_mlb_statsapi_etl_schedule_role,
    aws_iam_role_policy_attachment.sf_mlb_statsapi_etl_schedule_role__cloudwatch_logs_delivery_full_access_policy,
    aws_cloudwatch_log_group.sf_mlb_statsapi_etl_schedule_logs
  ]
}


output "sf_mlb_statsapi_etl_schedule-arn" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_schedule.arn
}

output "sf_mlb_statsapi_etl_schedule-name" {
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_schedule.name
}
