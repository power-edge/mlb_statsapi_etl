resource "aws_iam_role" "sf_mlb_statsapi_etl_gameday_role" {
  name = "sfn-${local.sf_mlb_statsapi_etl_gameday}-role-${var.aws_region}"
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


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__cloudwatch_logs_delivery_full_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.cloudwatch_logs_delivery_full_access_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_gameday_role.name
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__mlb_statsapi_sns_publish_workflow_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.mlb_statsapi_sns_publish_workflow_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_gameday_role.name
}


resource "aws_iam_policy" "gameday_invoke_lambda_scoped_access_policy" {
  name = "gameday_invoke_lambda_scoped_access_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          var.mlb_statsapi_states_gameday_date_in_season_lambda-arn,
          var.mlb_statsapi_states_gameday_set_scheduled_games_lambda-arn,
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_gameday_role__gameday_invoke_lambda_scoped_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.gameday_invoke_lambda_scoped_access_policy.arn
  role = aws_iam_role.sf_mlb_statsapi_etl_gameday_role.name
}
