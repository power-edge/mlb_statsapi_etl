resource "aws_s3_bucket" "mlb_statsapi_s3_data_bucket" {
  bucket = "mlb-statsapi-etl-${var.aws_region}-data"
  tags = {
    Name = "mlb-statsapi-etl-${var.aws_region}-data"
    Env = var.env_name
    Description = "Data Lake bucket for statsapi files"
  }
}

resource "aws_s3_bucket_public_access_block" "mlb_statsapi_s3_data_bucket_access_block" {
  bucket = aws_s3_bucket.mlb_statsapi_s3_data_bucket.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


resource "aws_iam_policy" "mlb_statsapi_s3_data_bucket_service_policy" {
  name = "mlb_statsapi_s3_data_bucket_service_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
        ]
        Resource = [
          "${aws_s3_bucket.mlb_statsapi_s3_data_bucket.arn}/*/api/v*/*.json.gz",
          "${aws_s3_bucket.mlb_statsapi_s3_data_bucket.arn}/*/api/v*/*.json.tar.gz"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
        ]
        Resource = aws_s3_bucket.mlb_statsapi_s3_data_bucket.arn
      }
    ]
  })
}
