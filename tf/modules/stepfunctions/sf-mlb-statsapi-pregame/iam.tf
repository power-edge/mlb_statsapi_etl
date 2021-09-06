resource "aws_iam_role" "sf_mlb_statsapi_etl_pregame_role" {
  name = "sfn-${local.sf_mlb_statsapi_etl_pregame}-role-${var.aws_region}"
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

resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_pregame_role__cloudwatch_logs_delivery_full_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.cloudwatch_logs_delivery_full_access_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.name
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_pregame_role__mlb_statsapi_sns_publish_event_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.mlb_statsapi_sns_publish_event_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.name
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_pregame_role__mlb_statsapi_sns_publish_workflow_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.mlb_statsapi_sns_publish_workflow_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.name
}


resource "aws_iam_policy" "pregame_invoke_lambda_scoped_access_policy" {
  name = "pregame_invoke_lambda_scoped_access_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          var.mlb_statsapi_states_pregame_set_game_lambda-arn
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_pregame_role__pregame_invoke_lambda_scoped_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.pregame_invoke_lambda_scoped_access_policy.arn
  role = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.name
}

resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_pregame_role__sf_mlb_statsapi_etl_game_mlb_statsapi_etl_runTask_policy" {
  policy_arn = var.sf_mlb_statsapi_etl_runTask_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.name
}

resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_pregame_role__iam_policy_snsPublish_pregame_forecast" {
  policy_arn = var.iam_policy_snsPublish_pregame_forecast-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.name
}