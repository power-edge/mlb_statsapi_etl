variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}
variable "env_name" {}

locals {
  sf_mlb_statsapi_etl_gamePk = "mlb_statsapi_etl_gamePk"
}


resource "aws_iam_role" "sf_mlb_statsapi_etl_gamePk_role" {
  name = "${local.sf_mlb_statsapi_etl_gamePk}-role-${var.aws_region}"
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

resource "aws_iam_policy" "cloudwatch_logs_delivery_full_access_policy" {
  name = "tf_cloudwatch_logs_delivery_full_access_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gamePk_role__cloudwatch_logs_delivery_full_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.cloudwatch_logs_delivery_full_access_policy.arn
  role = aws_iam_role.sf_mlb_statsapi_etl_gamePk_role.name
}


/*
resource "aws_iam_policy" "lambda_invoke_scoped_access_policy" {
  name = "lambda_invoke_scoped_access_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          "arn:aws:lambda:${var.aws_region}:${var.aws_account}:function:${var.mlb_statsapi_states_gameday_date_in_season_lambda-function_name}",
          "arn:aws:lambda:${var.aws_region}:${var.aws_account}:function:${var.mlb_statsapi_states_gameday_schedule_games_lambda-function_name}",
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gamePk_role__lambda_invoke_scoped_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.lambda_invoke_scoped_access_policy.arn
  role = aws_iam_role.sf_mlb_statsapi_etl_gamePk_role.name
}
*/


resource "aws_cloudwatch_log_group" "sf_mlb_statsapi_etl_gamePk_logs" {
  name = "/aws/vendedlogs/states/${local.sf_mlb_statsapi_etl_gamePk}"
  retention_in_days = 3
}


resource "aws_sfn_state_machine" "sf_mlb_statsapi_etl_gamePk" {
  name = local.sf_mlb_statsapi_etl_gamePk
  //noinspection HILUnresolvedReference
  role_arn = aws_iam_role.sf_mlb_statsapi_etl_gamePk_role.arn

  definition = <<DEFINITION
{
  "Comment": "State Machine ${local.sf_mlb_statsapi_etl_gamePk} handles the workflow for a give gamePk and gameDate.",
  "StartAt": "gamePk",
  "States": {
    "gamePk": {
      "Type": "Pass",
      "End": true
    }
  }
}
DEFINITION


  logging_configuration {
    //noinspection HILUnresolvedReference
    log_destination = "${aws_cloudwatch_log_group.sf_mlb_statsapi_etl_gamePk_logs.arn}:*"
    include_execution_data = true
    level = "ERROR"
  }
  depends_on = [
    aws_iam_role.sf_mlb_statsapi_etl_gamePk_role,
    aws_iam_policy.cloudwatch_logs_delivery_full_access_policy,
    aws_iam_role_policy_attachment.sf_mlb_statsapi_etl_gamePk_role__cloudwatch_logs_delivery_full_access_policy,
    aws_cloudwatch_log_group.sf_mlb_statsapi_etl_gamePk_logs
  ]
}


output "sf_mlb_statsapi_etl_gamePk-arn" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_gamePk.arn
}

output "sf_mlb_statsapi_etl_gamePk-name" {
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_gamePk.name
}

output "cloudwatch_logs_delivery_full_access_policy-arn" {
  //noinspection HILUnresolvedReference
  value = aws_iam_policy.cloudwatch_logs_delivery_full_access_policy.arn
}