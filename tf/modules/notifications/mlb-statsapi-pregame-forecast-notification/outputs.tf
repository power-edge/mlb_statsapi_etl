output "sns_mlb_statsapi_pregame_forecast-arn" {
  value = aws_sns_topic.sns_mlb_statsapi_pregame_forecast.arn
}

output "iam_policy_snsPublish_pregame_forecast-arn" {
  value = aws_iam_policy.iam_policy_snsPublish_pregame_forecast.arn
}