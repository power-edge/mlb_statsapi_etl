variable "aws_region" {}


locals {
  name = "mlb-statsapi-event-${var.aws_region}"
}

resource "aws_sns_topic" "sns_mlb_statsapi_event" {
  name = local.name
}

resource "aws_sqs_queue" "sqs_mlb_statsapi_event" {
  name = local.name
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

output "sns_mlb_statsapi_event_arn" {
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