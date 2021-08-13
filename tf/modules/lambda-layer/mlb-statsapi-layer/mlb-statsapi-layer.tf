variable "env_name" {}
variable "build_version" {}
variable "always_run" {}
variable "aws_region" {}

locals {
  layer_name = "mlb_statsapi"
}

resource "null_resource" "mlb_statsapi_layer_zip" {
  triggers = {
    always_run = var.always_run
  }
  provisioner "local-exec" {
    command = join("; ", [
      "cd tf/local-exec/lambda-layer",
      "export LAYER_NAME=${local.layer_name}",
      "export BUILD=${var.build_version}",
      "export ALWAYS_RUN=${var.always_run}",
      "./zip.sh",
      "cd - || exit 1"
    ])
  }

}

resource "aws_lambda_layer_version" "mlb_statsapi_lambda_layer_ver" {
  filename   = "./tf/local-exec/lambda-layer/${local.layer_name}-${var.always_run}.zip"
  layer_name = local.layer_name

  compatible_runtimes = [
    "python3.8"
  ]
  description = "Required for use of `requests`, `serde`, and (todo) project code."

  depends_on = [
    null_resource.mlb_statsapi_layer_zip
  ]
}

output "mlb_statsapi_lambda_layer_ver" {
  value = aws_lambda_layer_version.mlb_statsapi_lambda_layer_ver.version
}

output "mlb_statsapi_lambda_layer_arn" {
  value = aws_lambda_layer_version.mlb_statsapi_lambda_layer_ver.arn
}


/*
  AWSLambdaBasicExecutionRole
*/
data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "AWSLambdaBasicExecutionRole-arn" {
  value = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}