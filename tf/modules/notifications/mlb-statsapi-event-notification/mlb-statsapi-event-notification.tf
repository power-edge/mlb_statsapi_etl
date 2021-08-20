variable "aws_region" {}


locals {
  name = "mlb-statsapi-event-${var.aws_region}"
}

resource "aws_sns_topic" "sns_mlb_statsapi_event" {
  name = local.name
}


resource "aws_sqs_queue" "sqs_mlb_statsapi_event_deadletter" {
  name = "${local.name}-deadletter"
}


resource "aws_sqs_queue" "sqs_mlb_statsapi_event" {
  name = local.name
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_mlb_statsapi_event_deadletter.arn
    maxReceiveCount = 3
  })
}


resource "aws_sqs_queue_policy" "sqs_mlb_statsapi_event_queue_policy" {
  queue_url = aws_sqs_queue.sqs_mlb_statsapi_event.id

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
      "Resource": "${aws_sqs_queue.sqs_mlb_statsapi_event.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.sns_mlb_statsapi_event.arn}"
        }
      }
    }
  ]
}
POLICY
}


resource "aws_sns_topic_subscription" "sns_sub_mlb_statsapi_event" {
  topic_arn = aws_sns_topic.sns_mlb_statsapi_event.arn
  protocol = "sqs"
  endpoint = aws_sqs_queue.sqs_mlb_statsapi_event.arn
}


resource "aws_iam_policy" "mlb_statsapi_sns_publish_event_policy" {
  name = "mlb_statsapi_sns_publish_event_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = aws_sns_topic.sns_mlb_statsapi_event.arn
      }
    ]
  })
}


output "sns_mlb_statsapi_event-arn" {
  value = aws_sns_topic.sns_mlb_statsapi_event.arn
}

output "sqs_mlb_statsapi_event-arn" {
  value = aws_sqs_queue.sqs_mlb_statsapi_event.arn
}

output "sqs_mlb_statsapi_event-id" {
  value = aws_sqs_queue.sqs_mlb_statsapi_event.id
}

output "sqs_mlb_statsapi_event-name" {
  value = aws_sqs_queue.sqs_mlb_statsapi_event.name
}

output "mlb_statsapi_sns_publish_event_policy-arn" {
  value = aws_iam_policy.mlb_statsapi_sns_publish_event_policy.arn
}