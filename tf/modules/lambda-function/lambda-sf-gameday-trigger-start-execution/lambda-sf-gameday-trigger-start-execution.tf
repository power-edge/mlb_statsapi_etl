variable "env_name" {}
variable "build_version" {}
variable "always_run" {}
variable "aws_region" {}
variable "mlb_statsapi_lambda_layer_arn" {}
variable "sf_mlb_statsapi_etl_gameday" {}
variable "sf_mlb_statsapi_etl_gameday-arn" {}
variable "AWSLambdaBasicExecutionRole-arn" {}


locals {
  function_name = "mlb_statsapi-triggers-gameday-start_execution"
  handler = "mlb_statsapi.functions.triggers.gameday.start_execution.lambda_handler"
  handler_file = "src/mlb_statsapi/functions/triggers/gameday/start_execution.py"
}


resource "aws_iam_role" "mlb_statsapi_triggers_gameday_start_execution_lambda_role" {
  name = "${local.function_name}-role-${var.aws_region}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "mlb_statsapi_triggers_gameday_start_execution_lambda_role__AWSLambdaBasicExecutionRole-attachment" {
  policy_arn = var.AWSLambdaBasicExecutionRole-arn
  role = aws_iam_role.mlb_statsapi_triggers_gameday_start_execution_lambda_role.name
}


resource "aws_cloudwatch_log_group" "mlb_statsapi_triggers_gameday_start_execution_lambda-Logs" {
  name = "/aws/lambda/${aws_lambda_function.mlb_statsapi_triggers_gameday_start_execution_lambda.function_name}"
  retention_in_days = 3
}


resource "aws_iam_policy" "mlb_statsapi_triggers_gameday_start_execution_lambda_logs_policy" {
  name = "mlb_statsapi_triggers_gameday_start_execution_lambda_logs_policy-${var.aws_region}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "logs:*"
        Resource = [
          aws_cloudwatch_log_group.mlb_statsapi_triggers_gameday_start_execution_lambda-Logs.arn
        ]
      }
    ]
  })

  depends_on = [
    aws_cloudwatch_log_group.mlb_statsapi_triggers_gameday_start_execution_lambda-Logs
  ]
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__mlb_statsapi_triggers_gameday_start_execution_lambda_logs_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.mlb_statsapi_triggers_gameday_start_execution_lambda_logs_policy.arn
  role = aws_iam_role.mlb_statsapi_triggers_gameday_start_execution_lambda_role.name
  depends_on = [
    aws_iam_policy.mlb_statsapi_triggers_gameday_start_execution_lambda_logs_policy,
    aws_iam_role.mlb_statsapi_triggers_gameday_start_execution_lambda_role
  ]
}


resource "aws_iam_policy" "mlb_statsapi_triggers_gameday_start_execution_lambda_states_policy" {
  name = "mlb_statsapi_triggers_gameday_start_execution_lambda_states_policy-${var.aws_region}"


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "states:StartExecution"
        Resource = var.sf_mlb_statsapi_etl_gameday-arn
      }
    ]
  })

}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__mlb_statsapi_triggers_gameday_start_execution_lambda_states_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.mlb_statsapi_triggers_gameday_start_execution_lambda_states_policy.arn
  role = aws_iam_role.mlb_statsapi_triggers_gameday_start_execution_lambda_role.name
  depends_on = [
    aws_iam_policy.mlb_statsapi_triggers_gameday_start_execution_lambda_states_policy,
    aws_iam_role.mlb_statsapi_triggers_gameday_start_execution_lambda_role
  ]
}



resource "null_resource" "mlb_statsapi_triggers_gameday_start_execution_lambda_zip" {
  triggers = {
    always_run = var.always_run
  }
  provisioner "local-exec" {
    //noinspection HILUnresolvedReference
    command = join("; ", [
      "cd tf/local-exec/lambda-function",
      "export ALWAYS_RUN=${var.always_run}",
      "export HANDLER_FILE=${local.handler_file}",
      "./zip.sh ${local.function_name} ${var.build_version}",
      "cd - || exit 1"
    ])
  }
}

resource "aws_lambda_function" "mlb_statsapi_triggers_gameday_start_execution_lambda" {
  function_name = local.function_name
  handler = local.handler
  //noinspection HILUnresolvedReference
  role = aws_iam_role.mlb_statsapi_triggers_gameday_start_execution_lambda_role.arn
  filename = "tf/local-exec/lambda-function/${local.function_name}/${var.build_version}-${var.always_run}.zip"
  runtime = "python3.8"
  memory_size = 256
  timeout = 10

  layers = [
    var.mlb_statsapi_lambda_layer_arn
  ]

  environment {
    variables = {
      Description = "Trigger for states:StartExecution for the gameday Step Function"
      Env = var.env_name
      MLB_STATSAPI_ETL__CONFIGS_PATH = "/opt/configs"
      STATE_MACHINE_ARN = var.sf_mlb_statsapi_etl_gameday-arn
    }
  }

  depends_on = [
    aws_iam_role.mlb_statsapi_triggers_gameday_start_execution_lambda_role,
    null_resource.mlb_statsapi_triggers_gameday_start_execution_lambda_zip
  ]
}


resource "aws_cloudwatch_event_rule" "mlb_statsapi_etl_gameday_event_rule" {
  name = "${var.sf_mlb_statsapi_etl_gameday}_event_rule-${var.aws_region}"
  description = "Daily trigger for ${aws_lambda_function.mlb_statsapi_triggers_gameday_start_execution_lambda.arn} and ${var.sf_mlb_statsapi_etl_gameday-arn}"
  schedule_expression = "cron(0 8 * * ? *)"
//schedule_expression = "cron(0/5 * * * ? *)"  # At every 5th minute
  is_enabled = true
}

resource "aws_iam_role" "mlb_statsapi_etl-gameday-start_execution-event_trigger_role" {
  name = "mlb_statsapi-gameday-StartExecution-EventTriggerRole-${var.aws_region}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

}


resource "aws_iam_role_policy" "mlb_statsapi_etl-gameday-start_execution-event_trigger_role-policy" {
  name = "${local.function_name}_event_trigger_policy-${var.aws_region}"
  role = aws_iam_role.mlb_statsapi_etl-gameday-start_execution-event_trigger_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = aws_lambda_function.mlb_statsapi_triggers_gameday_start_execution_lambda.arn
      }
    ]
  })

}

resource "aws_cloudwatch_event_target" "mlb_statsapi_etl_gameday_event_target" {
  rule = aws_cloudwatch_event_rule.mlb_statsapi_etl_gameday_event_rule.name
  target_id = "${local.function_name}-StartExecution"
  arn = aws_lambda_function.mlb_statsapi_triggers_gameday_start_execution_lambda.arn
//  role_arn = aws_iam_role.mlb_statsapi_etl-gameday-start_execution-event_trigger_role.arn
}


resource "aws_lambda_permission" "allow_cloudwatch_to_call_mlb_statsapi_triggers_gameday_start_execution_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = local.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.mlb_statsapi_etl_gameday_event_rule.arn
}


output "mlb_statsapi_triggers_gameday_start_execution_lambda-function_name" {
  value = aws_lambda_function.mlb_statsapi_triggers_gameday_start_execution_lambda.function_name
}


output "mlb_statsapi_triggers_gameday_start_execution_lambda-arn" {
  //noinspection HILUnresolvedReference
  value = aws_lambda_function.mlb_statsapi_triggers_gameday_start_execution_lambda.arn
}