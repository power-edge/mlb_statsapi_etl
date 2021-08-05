variable "env_name" {
    type = string
    default = "dev"
    validation {
        condition = can(regex("mlb-statsapi-[a-z]+-[a-z]+-[1-9]", var.env_name))
        error_message = "The env_name must be mlb-statsapi-(us-region)."
    }
}

resource "aws_sns_topic" "sns_mlb_statsapi_schedule_games" {
  name = "sns_mlb_statsapi_schedule_games_${var.env_name}"
}

resource "aws_sqs_queue" "sqs_mlb_statsapi_schedule_games" {
  name = "sns_mlb_statsapi_schedule_games_${var.env_name}"
}

resource "aws_sns_topic_subscription" "sns_sub_mlb_statsapi_schedule" {
  topic_arn = aws_sns_topic.sns_mlb_statsapi_schedule_games.arn
  protocol = "sqs"
  endpoint = aws_sqs_queue.sqs_mlb_statsapi_schedule_games.arn
}

output "sns_mlb_statsapi_schedule_games_arn" {
  value = aws_sns_topic.sns_mlb_statsapi_schedule_games.arn
}

output "sqs_mlb_statsapi_schedule_games_arn" {
  value = aws_sqs_queue.sqs_mlb_statsapi_schedule_games.arn
}