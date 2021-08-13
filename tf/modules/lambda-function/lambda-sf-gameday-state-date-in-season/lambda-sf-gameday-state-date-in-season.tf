variable "env_name" {}
variable "build_version" {}
variable "always_run" {}
variable "aws_region" {}
variable "mlb_statsapi_lambda_layer_arn" {}
variable "AWSLambdaBasicExecutionRole-arn" {}


locals {
  function_name = "mlb_statsapi-states-gameday-date_in_season"
  handler = "mlb_statsapi.functions.states.gameday.date_in_season.lambda_handler"
  handler_file = "src/mlb_statsapi/functions/states/gameday/date_in_season.py"
}


resource "aws_iam_role" "mlb_statsapi_states_gameday_date_in_season_lambda_role" {
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


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__AWSLambdaBasicExecutionRole-attachment" {
  policy_arn = var.AWSLambdaBasicExecutionRole-arn
  role = aws_iam_role.mlb_statsapi_states_gameday_date_in_season_lambda_role.name
}



resource "aws_iam_policy" "mlb_statsapi_states_gameday_date_in_season_lambda_logs_policy" {
  name = "mlb_statsapi_states_gameday_date_in_season_lambda_logs_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "logs:*"
        Resource = [
          aws_cloudwatch_log_group.mlb_statsapi_states_gameday_date_in_season_lambda-Logs.arn
        ]
      }
    ]
  })

  depends_on = [
    aws_cloudwatch_log_group.mlb_statsapi_states_gameday_date_in_season_lambda-Logs
  ]
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__mlb_statsapi_states_gameday_date_in_season_lambda_logs_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.mlb_statsapi_states_gameday_date_in_season_lambda_logs_policy.arn
  role = aws_iam_role.mlb_statsapi_states_gameday_date_in_season_lambda_role.name
}


//resource "aws_iam_policy" "iam_policy_mlb_statsapi_schedule_schedule" {
//  policy = jsonencode({
//    Version = "2012-10-17"
//    Statement = [
//      {
//        Effect = "Allow"
//        Action = "sts:AssumeRole"
//        Principal = {
//          Service = "lambda-function-function.amazonaws.com"
//        }
//      }
//    ]
//  })
//}
//
//
//resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_mlb_statsapi_schedule_schedule" {
//  policy_arn = aws_iam_policy.iam_policy_mlb_statsapi_schedule_schedule.arn
//  role = aws_iam_role.iam_role_mlb_statsapi_schedule_schedule.arn
//}

resource "null_resource" "mlb_statsapi_states_gameday_date_in_season_lambda_zip" {
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

resource "aws_lambda_function" "mlb_statsapi_states_gameday_date_in_season_lambda" {
  function_name = local.function_name
  handler = local.handler
  //noinspection HILUnresolvedReference
  role = aws_iam_role.mlb_statsapi_states_gameday_date_in_season_lambda_role.arn
  filename = "tf/local-exec/lambda-function/${local.function_name}/${var.build_version}-${var.always_run}.zip"
  runtime = "python3.8"
  memory_size = 256
  timeout = 10

  layers = [
    var.mlb_statsapi_lambda_layer_arn
  ]

  environment {
    variables = {
      Description = "Boolean lambda for if a date is in-season"
      Env = var.env_name
      MLB_STATSAPI_ETL__CONFIGS_PATH = "/opt/configs"
    }
  }

  depends_on = [
    aws_iam_role.mlb_statsapi_states_gameday_date_in_season_lambda_role,
    null_resource.mlb_statsapi_states_gameday_date_in_season_lambda_zip,
  ]
}

resource "aws_cloudwatch_log_group" "mlb_statsapi_states_gameday_date_in_season_lambda-Logs" {
  name = "/aws/lambda/${aws_lambda_function.mlb_statsapi_states_gameday_date_in_season_lambda.function_name}"
  retention_in_days = 3
  depends_on = [
    aws_lambda_function.mlb_statsapi_states_gameday_date_in_season_lambda
  ]
}

output "mlb_statsapi_states_gameday_date_in_season_lambda-function_name" {
  value = aws_lambda_function.mlb_statsapi_states_gameday_date_in_season_lambda.function_name
}

output "mlb_statsapi_states_gameday_date_in_season_lambda-arn" {
  value = aws_lambda_function.mlb_statsapi_states_gameday_date_in_season_lambda.arn
}