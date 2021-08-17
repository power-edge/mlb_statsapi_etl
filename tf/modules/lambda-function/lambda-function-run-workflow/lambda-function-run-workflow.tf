variable "env_name" {}
variable "build_version" {}
variable "always_run" {}
variable "aws_region" {}
variable "aws_account" {}
variable "mlb_statsapi_lambda_layer_arn" {}

variable "AWSLambdaBasicExecutionRole-arn" {}

variable "sf_mlb_statsapi_etl_season-arn" {}
variable "sf_mlb_statsapi_etl_season-name" {}


locals {
  function_name = "mlb_statsapi-run_workflow"
  handler = "mlb_statsapi.functions.run_workflow.lambda_handler"
  handler_file = "src/mlb_statsapi/functions/run_workflow.py"
}


resource "aws_iam_role" "mlb_statsapi_run_workflow_lambda_role" {
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


resource "aws_iam_role_policy_attachment" "mlb_statsapi_run_workflow_lambda_role__AWSLambdaBasicExecutionRole-attachment" {
  policy_arn = var.AWSLambdaBasicExecutionRole-arn
  role = aws_iam_role.mlb_statsapi_run_workflow_lambda_role.name
}


resource "aws_cloudwatch_log_group" "mlb_statsapi_run_workflow_lambda-Logs" {
  name = "/aws/lambda/${aws_lambda_function.mlb_statsapi_run_workflow_lambda.function_name}"
  retention_in_days = 3
}


resource "aws_iam_policy" "mlb_statsapi_run_workflow_lambda_logs_policy" {
  name = "${local.function_name}-lambda_logs_policy-${var.aws_region}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "logs:*"
        Resource = [
          aws_cloudwatch_log_group.mlb_statsapi_run_workflow_lambda-Logs.arn
        ]
      }
    ]
  })

  depends_on = [
    aws_cloudwatch_log_group.mlb_statsapi_run_workflow_lambda-Logs
  ]
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__mlb_statsapi_run_workflow_lambda_logs_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.mlb_statsapi_run_workflow_lambda_logs_policy.arn
  role = aws_iam_role.mlb_statsapi_run_workflow_lambda_role.name
  depends_on = [
    aws_iam_policy.mlb_statsapi_run_workflow_lambda_logs_policy,
    aws_iam_role.mlb_statsapi_run_workflow_lambda_role
  ]
}


resource "aws_iam_policy" "mlb_statsapi_run_workflow_lambda_states_policy" {
  name = "mlb_statsapi_run_workflow_lambda_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "states:StartExecution"
        Resource = "arn:aws:states:${var.aws_region}:${var.aws_account}:stateMachine:mlb_statsapi*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__mlb_statsapi_run_workflow_lambda_states_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.mlb_statsapi_run_workflow_lambda_states_policy.arn
  role = aws_iam_role.mlb_statsapi_run_workflow_lambda_role.name
  depends_on = [
    aws_iam_policy.mlb_statsapi_run_workflow_lambda_states_policy,
    aws_iam_role.mlb_statsapi_run_workflow_lambda_role
  ]
}


resource "null_resource" "mlb_statsapi_run_workflow_lambda_zip" {
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

resource "aws_lambda_function" "mlb_statsapi_run_workflow_lambda" {
  function_name = local.function_name
  handler = local.handler
  //noinspection HILUnresolvedReference
  role = aws_iam_role.mlb_statsapi_run_workflow_lambda_role.arn
  filename = "tf/local-exec/lambda-function/${local.function_name}/${var.build_version}-${var.always_run}.zip"
  runtime = "python3.8"
  memory_size = 256
  timeout = 10

  layers = [
    var.mlb_statsapi_lambda_layer_arn
  ]

  environment {
    variables = {
      Description = "Handler to call start-execution for various step functions."
      Env = var.env_name
//      MLB_STATSAPI__CONFIGS_PATH = "/opt/configs"
      MLB_STATSAPI__SEASON_SFN_ARN = var.sf_mlb_statsapi_etl_season-arn
    }
  }

  depends_on = [
    aws_iam_role.mlb_statsapi_run_workflow_lambda_role,
    null_resource.mlb_statsapi_run_workflow_lambda_zip
  ]
}


resource "aws_cloudwatch_event_rule" "mlb_statsapi_season_event_rule" {
  name = "mlb_statsapi_season_event_rule-${var.aws_region}"
  description = "Yearly event to trigger the Season Workflow."

  // Minutes, Hours, Day-of-month, Month, Day-of-week, Year
  schedule_expression = "cron(0 9 12 2 ? *)"  # feb 12 every year at 9am UTC
  //  schedule_expression = "cron(0/2 * * * ? *)"  # At every 5th minute (testing)
  //  schedule_expression = "cron(0 8 * * ? *)"  # every day at 8am

  is_enabled = true
}


resource "aws_cloudwatch_event_target" "mlb_statsapi_season_event_target" {
  rule = aws_cloudwatch_event_rule.mlb_statsapi_season_event_rule.name
  target_id = "${local.function_name}-StartExecution-Season"
  arn = aws_lambda_function.mlb_statsapi_run_workflow_lambda.arn
  input_transformer {
    input_paths = {
    version = "$.version"
    id = "$.id"
    detail-type = "$.detail-type"
    source = "$.source"
    account = "$.account"
    time = "$.time"
    region = "$.region"
    resources = "$.resources"
    detail = "$.detail"
    }
    input_template = <<EOF
{
  "version": <version>,
  "id": <id>,
  "detail-type": <detail-type>,
  "source": <source>,
  "account": <account>,
  "time": <time>,
  "region": <region>,
  "resources": <resources>,
  "detail": <detail>,
  "workflow": {
    "name": "${var.sf_mlb_statsapi_etl_season-name}",
    "arn": "${var.sf_mlb_statsapi_etl_season-arn}"
  }
}
EOF
  }
}


resource "aws_lambda_permission" "allow_cloudwatch_season_event_to_call_run_workflow_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = local.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.mlb_statsapi_season_event_rule.arn
}


output "mlb_statsapi_run_workflow_lambda-function_name" {
  value = aws_lambda_function.mlb_statsapi_run_workflow_lambda.function_name
}


output "mlb_statsapi_run_workflow_lambda-arn" {
  //noinspection HILUnresolvedReference
  value = aws_lambda_function.mlb_statsapi_run_workflow_lambda.arn
}