variable "aws_region" {}


resource "aws_iam_policy" "cloudwatch_logs_delivery_full_access_policy" {
  name = "tf_cloudwatch_logs_delivery_full_access_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}


output "cloudwatch_logs_delivery_full_access_policy-arn" {
  value = aws_iam_policy.cloudwatch_logs_delivery_full_access_policy.arn
}