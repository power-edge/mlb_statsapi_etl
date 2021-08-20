variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}
variable "env_name" {}

variable "always_run-ecr-mlb-statsapi-etl-build" {}
variable "always_run-ecr-mlb-statsapi-etl-push" {}
variable "build_version" {}
variable "tag_latest" {}

locals {
  repository_name = "mlb-statsapi-etl"
}

resource "aws_ecr_repository" "ecr_repository_mlb_statsapi_etl" {
  name = local.repository_name
  tags = {
    Name = local.repository_name
    Env = var.env_name
  }
}

output "ecr_repository_mlb_statsapi_etl-name" {
  value = aws_ecr_repository.ecr_repository_mlb_statsapi_etl.name
}

output "ecr_repository_mlb_statsapi_etl-id" {
  value = aws_ecr_repository.ecr_repository_mlb_statsapi_etl.id
}

output "ecr_repository_mlb_statsapi_etl-arn" {
  value = aws_ecr_repository.ecr_repository_mlb_statsapi_etl.arn
}

output "ecr_repository_mlb_statsapi_etl-registry_id" {
  value = aws_ecr_repository.ecr_repository_mlb_statsapi_etl.registry_id
}

output "ecr_repository_mlb_statsapi_etl-repository_url" {
  value = aws_ecr_repository.ecr_repository_mlb_statsapi_etl.repository_url
}

resource "null_resource" "docker_build_mlb_statsapi_etl" {
  triggers = {
    always_run = var.always_run-ecr-mlb-statsapi-etl-build
  }
  provisioner "local-exec" {
    command = join("; ", [
      "export ALWAYS_RUN=${var.always_run-ecr-mlb-statsapi-etl-build}",
      "export AWS_PROFILE=${var.aws_profile}",
      "export AWS_ACCTOUNT=${var.aws_account}",
      "export AWS_REGION=${var.aws_region}",
      "export REPOSITORY_NAME=${local.repository_name}",
      "export BUILD_VERSION=${var.build_version}",
      "export TAG_LATEST=${var.tag_latest}",
      "docker/build.sh ${var.build_version} ${var.tag_latest}"
    ])
  }

  depends_on = [aws_ecr_repository.ecr_repository_mlb_statsapi_etl]
}

resource "null_resource" "docker_push_mlb_statsapi_etl" {
  triggers = {
    always_run = var.always_run-ecr-mlb-statsapi-etl-push
  }
  provisioner "local-exec" {
    command = join("; ", [
      "export ALWAYS_RUN=${var.always_run-ecr-mlb-statsapi-etl-push}",
      "export AWS_PROFILE=${var.aws_profile}",
      "export AWS_ACCOUNT=${var.aws_account}",
      "export AWS_REGION=${var.aws_region}",
      "export REPOSITORY_NAME=${local.repository_name}",
      "export BUILD_VERSION=${var.build_version}",
      "export TAG_LATEST=${var.tag_latest}",
      "docker/push.sh ${var.build_version} ${var.tag_latest}"
    ])
  }

  depends_on = [null_resource.docker_build_mlb_statsapi_etl]
}

data "aws_ecr_image" "mlb_statsapi_etl_image" {
  repository_name = aws_ecr_repository.ecr_repository_mlb_statsapi_etl.name
  image_tag = var.build_version

  depends_on = [
    null_resource.docker_push_mlb_statsapi_etl
  ]
}

output "mlb_statsapi_etl_image-repository_name" {
  value = data.aws_ecr_image.mlb_statsapi_etl_image.repository_name
}

output "mlb_statsapi_etl_image-image_digest" {
  value = data.aws_ecr_image.mlb_statsapi_etl_image.image_digest
}

