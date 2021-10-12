variable "aws_region" {}


locals {
  name = "mlb-statsapi-workflow-${var.aws_region}"
}

resource "aws_sns_topic" "sns_mlb_statsapi_workflow" {
  name = local.name
}

resource "aws_sqs_queue" "sqs_mlb_statsapi_workflow_deadletter" {
  name = "${local.name}-deadletter"
}

resource "aws_sns_topic" "sns_mlb_statsapi_workflow_deadletter_alarm" {
  name = "${local.name}-deadletter-alarm"
}

resource "aws_sns_topic_subscription" "sns_mlb_statsapi_workflow_deadletter_alarm_subscription" {
  endpoint = "+12152785721"
  protocol = "sms"
  topic_arn = aws_sns_topic.sns_mlb_statsapi_workflow_deadletter_alarm.arn
}

resource "aws_cloudwatch_metric_alarm" "sqs_mlb_statsapi_workflow_deadletter_alarm" {
  alarm_description = "This alarm is to notify in case of run_workflow failure to start-execution of a Step Function."
  alarm_name = "${local.name}-deadletter-alarm"
  evaluation_periods = "1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold = "2"
  metric_name = "Errors"
  namespace = "AWS/Lambda"
  period = "120"
  statistic = "Sum"
  unit = "Count"
  alarm_actions = [
    aws_sns_topic.sns_mlb_statsapi_workflow_deadletter_alarm.arn
  ]
  actions_enabled = true
}

resource "aws_sqs_queue" "sqs_mlb_statsapi_workflow" {
  name = local.name
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_mlb_statsapi_workflow_deadletter.arn
    maxReceiveCount = 2
  })
}


resource "aws_sqs_queue_policy" "sqs_mlb_statsapi_workflow_queue_policy" {
  queue_url = aws_sqs_queue.sqs_mlb_statsapi_workflow.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.sqs_mlb_statsapi_workflow.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.sns_mlb_statsapi_workflow.arn}"
        }
      }
    }
  ]
}
POLICY
}


resource "aws_sns_topic_subscription" "sns_sub_mlb_statsapi_workflow" {
  topic_arn = aws_sns_topic.sns_mlb_statsapi_workflow.arn
  protocol = "sqs"
  endpoint = aws_sqs_queue.sqs_mlb_statsapi_workflow.arn
}


resource "aws_iam_policy" "mlb_statsapi_sns_publish_workflow_policy" {
  name = "mlb_statsapi_sns_publish_workflow_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = aws_sns_topic.sns_mlb_statsapi_workflow.arn
      }
    ]
  })
}


output "sns_mlb_statsapi_workflow-arn" {
  value = aws_sns_topic.sns_mlb_statsapi_workflow.arn
}

output "sqs_mlb_statsapi_workflow-arn" {
  value = aws_sqs_queue.sqs_mlb_statsapi_workflow.arn
}

output "sqs_mlb_statsapi_workflow-id" {
  value = aws_sqs_queue.sqs_mlb_statsapi_workflow.id
}

output "sqs_mlb_statsapi_workflow-name" {
  value = aws_sqs_queue.sqs_mlb_statsapi_workflow.name
}

output "mlb_statsapi_sns_publish_workflow_policy-arn" {
  value = aws_iam_policy.mlb_statsapi_sns_publish_workflow_policy.arn
}