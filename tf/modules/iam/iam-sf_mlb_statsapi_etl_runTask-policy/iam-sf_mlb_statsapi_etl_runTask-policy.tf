variable "aws_region" {}
variable "ecs_task_definition_mlb_statsapi_etl-arn" {}
variable "ecs_mlb_statsapi_etl-taskRole-arn" {}
variable "ecs_mlb_statsapi_etl-taskExecutionRole-arn" {}


resource "aws_iam_policy" "sf_mlb_statsapi_etl_runTask_policy" {
  name = "sf_mlb_statsapi_etl_runTask_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "ecs:RunTask"
        Resource = var.ecs_task_definition_mlb_statsapi_etl-arn
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          var.ecs_mlb_statsapi_etl-taskRole-arn,
          var.ecs_mlb_statsapi_etl-taskExecutionRole-arn
        ]
      }
    ]
  })
}

output "sf_mlb_statsapi_etl_runTask_policy-arn" {
  value = aws_iam_policy.sf_mlb_statsapi_etl_runTask_policy.arn
}