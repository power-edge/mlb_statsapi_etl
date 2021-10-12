resource "aws_iam_role" "sf_mlb_statsapi_etl_game_role" {
  name = "sfn-${local.sf_mlb_statsapi_etl_game}-role-${var.aws_region}"
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


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_game_role__cloudwatch_logs_delivery_full_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.cloudwatch_logs_delivery_full_access_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_game_role.name
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_game_role__sf_mlb_statsapi_etl_game_mlb_statsapi_etl_runTask_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.sf_mlb_statsapi_etl_runTask_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_game_role.name
}
