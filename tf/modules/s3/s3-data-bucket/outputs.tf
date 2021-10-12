output "mlb_statsapi_s3_data_bucket" {
  value = aws_s3_bucket.mlb_statsapi_s3_data_bucket.bucket
}

output "mlb_statsapi_s3_data_bucket_arn" {
  value = aws_s3_bucket.mlb_statsapi_s3_data_bucket.arn
}

output "mlb_statsapi_s3_data_bucket_service_policy-arn" {
  value = aws_iam_policy.mlb_statsapi_s3_data_bucket_service_policy.arn
}

output "sns_objectCreated_arn" {
  value = aws_sns_topic.objectCreated.arn
}