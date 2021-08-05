variable "env_name" {}
variable "aws_region" {}


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

output "mlb_statsapi_s3_data_bucket" {
  value = aws_s3_bucket.mlb_statsapi_s3_data_bucket.bucket
}
