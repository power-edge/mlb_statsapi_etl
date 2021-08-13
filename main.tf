variable "aws_profile" {}
variable "env_name" {}
variable "aws_region" {}
variable "aws_account" {}
variable "project_name" {}

variable "vpc_cidr_block" {}
variable "sn_prv_a0_cidr_block" {}
variable "sn_prv_b0_cidr_block" {}
variable "sn_pub_a0_cidr_block" {}
variable "sn_pub_b0_cidr_block" {}

// always_run for local-exec
variable "always_run-ecr-mlb-statsapi-etl-build" {}
variable "always_run-ecr-mlb-statsapi-etl-push" {}
variable "always_run-lambda-layer-mlb-statsapi" {}
variable "always_run-lambda-sf-gameday-state-date-in-season" {}
variable "always_run-lambda-sf-gameday-state-set-scheduled-games" {}
variable "always_run-lambda-sf-gameday-trigger-start-execution" {}

terraform {
    backend "s3" {
        bucket = "power-edge-sports.terraform"
    }
}


provider "aws" {
    region = var.aws_region
}


locals {
    always_run-ecr-mlb-statsapi-etl-build = coalesce(var.always_run-ecr-mlb-statsapi-etl-build, timestamp())
    always_run-ecr-mlb-statsapi-etl-push = coalesce(var.always_run-ecr-mlb-statsapi-etl-push, timestamp())
    always_run-lambda-layer-mlb-statsapi = coalesce(var.always_run-lambda-layer-mlb-statsapi, timestamp())
    always_run-lambda-sf-gameday-state-date-in-season = coalesce(var.always_run-lambda-sf-gameday-state-date-in-season, timestamp())
    always_run-lambda-sf-gameday-state-set-scheduled-games = coalesce(var.always_run-lambda-sf-gameday-state-set-scheduled-games, timestamp())
    always_run-lambda-sf-gameday-trigger-start-execution = coalesce(var.always_run-lambda-sf-gameday-trigger-start-execution, timestamp())
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


module "mlb-statsapi-vpc" {
    source = "./tf/modules/vpc"

    env_name = var.env_name
    aws_profile = var.aws_profile
    aws_account = var.aws_account
    aws_region = var.aws_region

    vpc_cidr_block = var.vpc_cidr_block
    sn_prv_a0_cidr_block = var.sn_prv_a0_cidr_block
    sn_prv_b0_cidr_block = var.sn_prv_b0_cidr_block
    sn_pub_a0_cidr_block = var.sn_pub_a0_cidr_block
    sn_pub_b0_cidr_block = var.sn_pub_b0_cidr_block
}


module "ecr-mlb-statsapi-etl-repository" {
    source = "./tf/modules/ecr/mlb-statsapi-etl"

    env_name = var.env_name

    aws_profile = var.aws_profile
    aws_account = var.aws_account
    aws_region = var.aws_region
    tag_latest = true

    always_run-ecr-mlb-statsapi-etl-build = local.always_run-ecr-mlb-statsapi-etl-build
    always_run-ecr-mlb-statsapi-etl-push = local.always_run-ecr-mlb-statsapi-etl-push
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

    build_version = module.variables.build

    mlb_statsapi_etl_image-repository_name = module.ecr-mlb-statsapi-etl-repository.mlb_statsapi_etl_image-repository_name

    mlb_statsapi_s3_data_bucket_service_policy-arn = module.s3-data-bucket.mlb_statsapi_s3_data_bucket_service_policy-arn

    depends_on = [
        module.ecr-mlb-statsapi-etl-repository
    ]

}


module "lambda-layer-mlb-statsapi" {
    source = "./tf/modules/lambda-layer/mlb-statsapi-layer"

    aws_region = var.aws_region
    env_name = var.env_name
    build_version = module.variables.build
    always_run = local.always_run-lambda-layer-mlb-statsapi
}


module "lambda-sf-gameday-state-date-in-season" {
    source = "./tf/modules/lambda-function/lambda-sf-gameday-state-date-in-season"

    aws_region = var.aws_region
    env_name = var.env_name
    build_version = module.variables.build
    always_run = local.always_run-lambda-sf-gameday-state-date-in-season
    mlb_statsapi_lambda_layer_arn = module.lambda-layer-mlb-statsapi.mlb_statsapi_lambda_layer_arn
    AWSLambdaBasicExecutionRole-arn = module.lambda-layer-mlb-statsapi.AWSLambdaBasicExecutionRole-arn

    depends_on = [
        module.lambda-layer-mlb-statsapi
    ]
}


module "lambda-sf-gameday-state-set-scheduled-games" {
    source = "./tf/modules/lambda-function/lambda-sf-gameday-state-set-scheduled-games"

    aws_region = var.aws_region
    env_name = var.env_name
    build_version = module.variables.build
    always_run = local.always_run-lambda-sf-gameday-state-set-scheduled-games
    mlb_statsapi_lambda_layer_arn = module.lambda-layer-mlb-statsapi.mlb_statsapi_lambda_layer_arn
    AWSLambdaBasicExecutionRole-arn = module.lambda-layer-mlb-statsapi.AWSLambdaBasicExecutionRole-arn

    depends_on = [
        module.lambda-layer-mlb-statsapi
    ]
}


////dynamodb-mlb-statsapi-gameday.tf
//module "dynamodb-mlb-statsapi-gameday" {
//    source = "./tf/modules/dynamodb/dynamodb-mlb-statsapi-gameday"
//    env_name = var.env_name
//    aws_profile = var.aws_profile
//    aws_account = var.aws_account
//    aws_region = var.aws_region
//}


module "sf-mlb-statsapi-gamePk" {
    source = "./tf/modules/stepfunctions/sf-mlb-statsapi-gamePk"

    env_name = var.env_name
    aws_profile = var.aws_profile
    aws_account = var.aws_account
    aws_region = var.aws_region

}


module "sf-mlb-statsapi-gameday" {
    source = "./tf/modules/stepfunctions/sf-mlb-statsapi-gameday"

    env_name = var.env_name
    aws_profile = var.aws_profile
    aws_account = var.aws_account
    aws_region = var.aws_region

    mlb_statsapi_states_gameday_date_in_season_lambda-function_name = module.lambda-sf-gameday-state-date-in-season.mlb_statsapi_states_gameday_date_in_season_lambda-function_name
    mlb_statsapi_states_gameday_date_in_season_lambda-arn = module.lambda-sf-gameday-state-date-in-season.mlb_statsapi_states_gameday_date_in_season_lambda-arn

    mlb_statsapi_states_gameday_set_scheduled_games_lambda-function_name = module.lambda-sf-gameday-state-set-scheduled-games.mlb_statsapi_states_gameday_set_scheduled_games_lambda-function_name
    mlb_statsapi_states_gameday_set_scheduled_games_lambda-arn = module.lambda-sf-gameday-state-set-scheduled-games.mlb_statsapi_states_gameday_set_scheduled_games_lambda-arn

    cloudwatch_logs_delivery_full_access_policy-arn = module.sf-mlb-statsapi-gamePk.cloudwatch_logs_delivery_full_access_policy-arn

    sf_mlb_statsapi_etl_gamePk-arn = module.sf-mlb-statsapi-gamePk.sf_mlb_statsapi_etl_gamePk-arn
    sf_mlb_statsapi_etl_gamePk-name = module.sf-mlb-statsapi-gamePk.sf_mlb_statsapi_etl_gamePk-name

    mlb_statsapi_etl_image-repository_name = module.ecr-mlb-statsapi-etl-repository.mlb_statsapi_etl_image-repository_name
    ecs_cluster_mlb_statsapi_etl-arn = module.ecs-mlb-statsapi-etl-task.ecs_cluster_mlb_statsapi_etl-arn

    ecs_task_definition_mlb_statsapi_etl-arn = module.ecs-mlb-statsapi-etl-task.ecs_task_definition_mlb_statsapi_etl-arn

    ecs_mlb_statsapi_etl-taskExecutionRole-arn = module.ecs-mlb-statsapi-etl-task.ecs_mlb_statsapi_etl-taskExecutionRole-arn
    ecs_mlb_statsapi_etl-taskRole-arn = module.ecs-mlb-statsapi-etl-task.ecs_mlb_statsapi_etl-taskRole-arn

    mlb_statsapi_sg-id = module.mlb-statsapi-vpc.mlb_statsapi_sg-id
    sn_pub_a0_id = module.mlb-statsapi-vpc.sn_pub_a0_id
    sn_pub_b0_id = module.mlb-statsapi-vpc.sn_pub_b0_id

    depends_on = [
        module.mlb-statsapi-vpc,
        module.lambda-sf-gameday-state-date-in-season,
        module.lambda-sf-gameday-state-set-scheduled-games,
        module.sf-mlb-statsapi-gamePk
    ]

}


module "lambda-sf-gameday-trigger-start-execution" {
    source = "./tf/modules/lambda-function/lambda-sf-gameday-trigger-start-execution"

    aws_region = var.aws_region
    env_name = var.env_name
    build_version = module.variables.build
    always_run = local.always_run-lambda-sf-gameday-trigger-start-execution
    mlb_statsapi_lambda_layer_arn = module.lambda-layer-mlb-statsapi.mlb_statsapi_lambda_layer_arn

    sf_mlb_statsapi_etl_gameday = module.sf-mlb-statsapi-gameday.sf_mlb_statsapi_etl_gameday
    sf_mlb_statsapi_etl_gameday-arn = module.sf-mlb-statsapi-gameday.sf_mlb_statsapi_etl_gameday-arn

    AWSLambdaBasicExecutionRole-arn = module.lambda-layer-mlb-statsapi.AWSLambdaBasicExecutionRole-arn

    depends_on = [
        module.variables,
        module.lambda-layer-mlb-statsapi,
        module.sf-mlb-statsapi-gameday,
    ]
}


//module "notifications" {
//    source = "./tf/notifications"
//    env_name = var.env_name
//}


//module "lambda-function-function" {
//    source = "./tf/lambda-function-function"
//    env_name = var.env_name
//    sns_mlb_statsapi_set_scheduled_games_arn = module.notifications.sns_mlb_statsapi_set_scheduled_games_arn
//}
