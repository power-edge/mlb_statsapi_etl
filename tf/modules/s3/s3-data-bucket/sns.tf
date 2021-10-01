locals {
  name = "s3-${aws_s3_bucket.mlb_statsapi_s3_data_bucket.bucket}-ObjectCreated"
}
resource "aws_sns_topic" "objectCreated" {
  name = local.name

  policy = <<POLICY
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
     "Service": "s3.amazonaws.com"
   },
   "Action": [
    "SNS:Publish"
   ],
   "Resource": "arn:aws:sns:${var.aws_region}:${var.aws_account}:${local.name}",
   "Condition": {
      "ArnLike": { "aws:SourceArn": "${aws_s3_bucket.mlb_statsapi_s3_data_bucket.arn}" },
      "StringEquals": { "aws:SourceAccount": "${var.aws_account}" }
   }
  }
 ]
}
POLICY
}

resource "aws_s3_bucket_notification" "objectCreated" {
  bucket = aws_s3_bucket.mlb_statsapi_s3_data_bucket.id
  depends_on = [
    aws_s3_bucket.mlb_statsapi_s3_data_bucket,
    aws_sns_topic.objectCreated,
  ]
  topic {
    topic_arn     = aws_sns_topic.objectCreated.arn
    events        = ["s3:ObjectCreated:*"]
  }
}