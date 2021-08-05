variable "aws_profile" {}
variable "env_name" {}
variable "aws_region" {}
variable "aws_account" {}
variable "project_name" {}

variable "vpc" {}
variable "sn_prv_a_00" {}
variable "sn_prv_b_00" {}
variable "sn_prv_d_00" {}
variable "sn_pub_a_00" {}
variable "sn_pub_b_00" {}
variable "sn_pub_d_00" {}

// always_run for local-exec
variable "run-ecr-mlb-statsapi-etl-build" {}
variable "run-ecr-mlb-statsapi-etl-push" {}

terraform {
    backend "s3" {
        bucket = "power-edge-sports.terraform"
    }
}

provider "aws" {
    region = var.aws_region
}

locals {
    run-ecr-mlb-statsapi-etl-build = coalesce(var.run-ecr-mlb-statsapi-etl-build, timestamp())
    run-ecr-mlb-statsapi-etl-push = coalesce(var.run-ecr-mlb-statsapi-etl-push, timestamp())
}

module "variables" {
    source = "./tf/variables"
}


module "s3-code-bucket" {
    source = "./tf/modules/s3/s3-code-bucket"
    env_name = var.env_name
    aws_region = var.aws_region
}

module "s3-data-bucket" {
    source = "./tf/modules/s3/s3-data-bucket"
    env_name = var.env_name
    aws_region = var.aws_region
}

module "ecr-mlb-statsapi-etl-repository" {
    source = "./tf/modules/ecr/mlb-statsapi-etl"

    env_name = var.env_name

    aws_profile = var.aws_profile
    aws_account = var.aws_account
    aws_region = var.aws_region
    tag_latest = true

    run-ecr-mlb-statsapi-etl-build = local.run-ecr-mlb-statsapi-etl-build
    run-ecr-mlb-statsapi-etl-push = local.run-ecr-mlb-statsapi-etl-push
    build_version = module.variables.build

    depends_on = [
        module.variables
    ]

}


module "ecs-mlb-statsapi-etl-task" {
    source = "./tf/modules/ecs/mlb-statsapi-etl"

    env_name = var.env_name

    aws_profile = var.aws_profile
    aws_account = var.aws_account
    aws_region = var.aws_region

    run-ecr-mlb-statsapi-etl-build = local.run-ecr-mlb-statsapi-etl-build
    run-ecr-mlb-statsapi-etl-push = local.run-ecr-mlb-statsapi-etl-push
    build_version = module.variables.build

    mlb_statsapi_etl_image-repository_name = module.ecr-mlb-statsapi-etl-repository.mlb_statsapi_etl_image-repository_name

    depends_on = [
        module.ecr-mlb-statsapi-etl-repository
    ]

}


//module "notifications" {
//    source = "./tf/notifications"
//    env_name = var.env_name
//}
//
//module "lambda" {
//    source = "./tf/lambda"
//    env_name = var.env_name
//    sns_mlb_statsapi_schedule_games_arn = module.notifications.sns_mlb_statsapi_schedule_games_arn
//}