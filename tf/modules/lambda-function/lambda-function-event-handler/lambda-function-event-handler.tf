variable "env_name" {}
variable "build_version" {}
variable "always_run" {}
variable "aws_region" {}
variable "aws_account" {}
variable "mlb_statsapi_lambda_layer_arn" {}

variable "AWSLambdaBasicExecutionRole-arn" {}
variable "mlb_statsapi_s3_data_bucket_service_policy-arn" {}

variable "sqs_mlb_statsapi_event-arn" {}
variable "sqs_mlb_statsapi_event-id" {}
variable "sqs_mlb_statsapi_event-name" {}


locals {
  function_name = "mlb_statsapi-event_handler"
  handler = "mlb_statsapi.functions.event_handler.lambda_handler"
  handler_file = "src/mlb_statsapi/functions/event_handler.py"
}


resource "aws_iam_role" "mlb_statsapi_event_handler_lambda_role" {
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


resource "aws_iam_role_policy_attachment" "mlb_statsapi_event_handler_lambda_role__AWSLambdaBasicExecutionRole-attachment" {
  policy_arn = var.AWSLambdaBasicExecutionRole-arn
  role = aws_iam_role.mlb_statsapi_event_handler_lambda_role.name
}


resource "aws_iam_role_policy_attachment" "mlb_statsapi_event_handler_lambda_role__mlb_statsapi_s3_data_bucket_service_policy-attachment" {
  policy_arn = var.mlb_statsapi_s3_data_bucket_service_policy-arn
  role = aws_iam_role.mlb_statsapi_event_handler_lambda_role.name
}


resource "aws_cloudwatch_log_group" "mlb_statsapi_event_handler_lambda-Logs" {
  name = "/aws/lambda/${aws_lambda_function.mlb_statsapi_event_handler_lambda.function_name}"
  retention_in_days = 3
}


resource "aws_iam_policy" "mlb_statsapi_event_handler_lambda_logs_policy" {
  name = "${local.function_name}-lambda_logs_policy-${var.aws_region}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "logs:*"
        Resource = [
          aws_cloudwatch_log_group.mlb_statsapi_event_handler_lambda-Logs.arn
        ]
      }
    ]
  })

  depends_on = [
    aws_cloudwatch_log_group.mlb_statsapi_event_handler_lambda-Logs
  ]
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__mlb_statsapi_event_handler_lambda_logs_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.mlb_statsapi_event_handler_lambda_logs_policy.arn
  role = aws_iam_role.mlb_statsapi_event_handler_lambda_role.name
  depends_on = [
    aws_iam_policy.mlb_statsapi_event_handler_lambda_logs_policy,
    aws_iam_role.mlb_statsapi_event_handler_lambda_role
  ]
}


resource "aws_iam_policy" "mlb_statsapi_event_handler_lambda_sqs_policy" {
  name = "${local.function_name}-lambda_sqs_policy-${var.aws_region}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sqs:*"
        Resource = var.sqs_mlb_statsapi_event-arn
      }
    ]
  })

  depends_on = [
    aws_cloudwatch_log_group.mlb_statsapi_event_handler_lambda-Logs
  ]
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__mlb_statsapi_event_handler_lambda_sqs_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.mlb_statsapi_event_handler_lambda_sqs_policy.arn
  role = aws_iam_role.mlb_statsapi_event_handler_lambda_role.name
  depends_on = [
    aws_iam_policy.mlb_statsapi_event_handler_lambda_sqs_policy,
    aws_iam_role.mlb_statsapi_event_handler_lambda_role
  ]
}


resource "null_resource" "mlb_statsapi_event_handler_lambda_zip" {
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

resource "aws_lambda_function" "mlb_statsapi_event_handler_lambda" {
  function_name = local.function_name
  handler = local.handler
  //noinspection HILUnresolvedReference
  role = aws_iam_role.mlb_statsapi_event_handler_lambda_role.arn
  filename = "tf/local-exec/lambda-function/${local.function_name}/${var.build_version}-${var.always_run}.zip"
  runtime = "python3.8"
  memory_size = 256
  timeout = 10

  layers = [
    var.mlb_statsapi_lambda_layer_arn
  ]

  environment {
    variables = {
      Description = "Lambda handler to consume from the mlb-statsapi-event queue."
      Env = var.env_name
      REGION = var.aws_region
      MLB_STATSAPI__BASE_FILE_PATH = "/tmp/.var/mlb_statsapi"
      MLB_STATSAPI__CONFIGS_PATH = "/opt/configs"
      MLB_STATSAPI__EVENT_QUEUE_URL = var.sqs_mlb_statsapi_event-id
    }
  }

  depends_on = [
    aws_iam_role.mlb_statsapi_event_handler_lambda_role,
    null_resource.mlb_statsapi_event_handler_lambda_zip
  ]
}


resource "aws_lambda_event_source_mapping" "mlb_statsapi_event_lambda_sqs_event_source_mapping" {
  event_source_arn = var.sqs_mlb_statsapi_event-arn
  function_name = aws_lambda_function.mlb_statsapi_event_handler_lambda.arn
}


output "mlb_statsapi_event_handler_lambda-function_name" {
  value = aws_lambda_function.mlb_statsapi_event_handler_lambda.function_name
}


output "mlb_statsapi_event_handler_lambda-arn" {
  //noinspection HILUnresolvedReference
  value = aws_lambda_function.mlb_statsapi_event_handler_lambda.arn
}