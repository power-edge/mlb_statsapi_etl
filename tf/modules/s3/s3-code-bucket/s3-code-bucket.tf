variable "env_name" {}
variable "aws_region" {}
variable "run-mlb_statsapi_s3_code_deploy" {default = ""}

/*
resource "aws_s3_bucket" "mlb_statsapi_s3_code_bucket" {
  bucket = "mlb-statsapi-etl-${var.aws_region}-code"
  tags = {
    Name = "mlb-statsapi-etl-${var.aws_region}-code"
    Env = var.env_name
    Description = "Code Bucket for mlb-statsapi"
  }
}
*/

/*
resource "aws_s3_bucket_public_access_block" "mlb_statsapi_s3_code_bucket_access_block" {
  bucket = aws_s3_bucket.mlb_statsapi_s3_code_bucket.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
*/

//resource "null_resource" "mlb_statsapi_s3_code_deploy" {
//  triggers = {
//    always_run = var.run-mlb_statsapi_s3_code_deploy
//  }
//  provisioner "local-exec" {
//    //noinspection HILUnresolvedReference
//    command = join("; ", [
//      "echo 'TODO: ${var.run-mlb_statsapi_s3_code_deploy}'"
//    ])
//  }
//}

/*
output "mlb_statsapi_s3_code_bucket" {
  value = aws_s3_bucket.mlb_statsapi_s3_code_bucket.bucket
}*/
