
variable "env_name" {
    type = string
    validation {
        condition = can(regex("[dev|qa|prod]", var.env_name))
        error_message = "The env must be (dev,qa,prod)."
    }
}

variable "sns_mlb_statsapi_schedule_games_arn" {
    type = string
}

resource "aws_iam_role" "iam_role_mlb_statsapi_schedule_schedule" {
  name_prefix = "mlb_statsapi_schedule_schedule"
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


resource "aws_iam_policy" "iam_policy_mlb_statsapi_schedule_schedule" {
  policy = jsonencode({
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


resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_mlb_statsapi_schedule_schedule" {
  policy_arn = aws_iam_policy.iam_policy_mlb_statsapi_schedule_schedule.arn
  role = aws_iam_role.iam_role_mlb_statsapi_schedule_schedule.arn
}


resource "aws_lambda_function" "mlb_statsapi_schedule_schedule" {
  function_name = "mlb_statsapi.StatsAPI.Schedule.schedule"
  handler = "mlb_statsapi.lambdas.schedule.schedule"
  role = aws_iam_role.iam_role_mlb_statsapi_schedule_schedule.arn
  runtime = "python3.8"

  environment {
    variables = {
      Env = var.env_name
      GAME_TOPIC_ARN = var.sns_mlb_statsapi_schedule_games_arn
      Description = "Save the schedule to s3 and send an sns notification for each game"
    }
  }
}