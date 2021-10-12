resource "aws_sns_topic" "sns_mlb_statsapi_pregame_forecast" {
  name = local.name
}


resource "aws_iam_policy" "iam_policy_snsPublish_pregame_forecast" {
  name = "${local.name}-snsPublish-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = aws_sns_topic.sns_mlb_statsapi_pregame_forecast.arn
      }
    ]
  })
}
