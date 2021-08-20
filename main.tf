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
variable "always_run-lambda-function-run-workflow" {}
variable "always_run-lambda-function-event-handler" {}
variable "always_run-lambda-sf-season-state-set-season" {}
variable "always_run-lambda-sf-gameday-state-date-in-season" {}
variable "always_run-lambda-sf-gameday-state-set-scheduled-games" {}
variable "always_run-lambda-sf-pregame-state-set-game" {}
variable "always_run-lambda-sf-pregame-state-set-team" {}


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

    always_run-lambda-function-run-workflow = coalesce(var.always_run-lambda-function-run-workflow, timestamp())
    always_run-lambda-function-event-handler = coalesce(var.always_run-lambda-function-event-handler, timestamp())

    always_run-lambda-sf-season-state-set-season = coalesce(var.always_run-lambda-sf-season-state-set-season, timestamp())

    always_run-lambda-sf-gameday-state-date-in-season = coalesce(var.always_run-lambda-sf-gameday-state-date-in-season, timestamp())
    always_run-lambda-sf-gameday-state-set-scheduled-games = coalesce(var.always_run-lambda-sf-gameday-state-set-scheduled-games, timestamp())

    always_run-lambda-sf-pregame-state-set-game = coalesce(var.always_run-lambda-sf-pregame-state-set-game, timestamp())
    always_run-lambda-sf-pregame-state-set-team = coalesce(var.always_run-lambda-sf-pregame-state-set-team, timestamp())
}


module "variables" {
    source = "./tf/variables"
}

module "iam-logs-delivery-full-access-policy" {
    source = "./tf/modules/iam/iam-logs-delivery-full-access-policy"
    aws_region = var.aws_region

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

module "mlb-statsapi-event-notification" {
    source = "./tf/modules/notifications/mlb-statsapi-event-notification"
    aws_region = var.aws_region
}


module "mlb-statsapi-workflow-notification" {
    source = "./tf/modules/notifications/mlb-statsapi-workflow-notification"
    aws_region = var.aws_region
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
    mlb_statsapi_sns_publish_event_policy-arn = module.mlb-statsapi-event-notification.mlb_statsapi_sns_publish_event_policy-arn

    depends_on = [
        module.variables,
        module.ecr-mlb-statsapi-etl-repository,
        module.s3-data-bucket
    ]

}

module "iam-sf_mlb_statsapi_etl_runTask-policy" {
    source = "./tf/modules/iam/iam-sf_mlb_statsapi_etl_runTask-policy"

    aws_region = var.aws_region

    ecs_mlb_statsapi_etl-taskExecutionRole-arn = module.ecs-mlb-statsapi-etl-task.ecs_mlb_statsapi_etl-taskExecutionRole-arn
    ecs_mlb_statsapi_etl-taskRole-arn = module.ecs-mlb-statsapi-etl-task.ecs_mlb_statsapi_etl-taskRole-arn
    ecs_task_definition_mlb_statsapi_etl-arn = module.ecs-mlb-statsapi-etl-task.ecs_task_definition_mlb_statsapi_etl-arn
}


module "sf-mlb-statsapi-game" {
    source = "./tf/modules/stepfunctions/sf-mlb-statsapi-game"

    env_name = var.env_name
    aws_profile = var.aws_profile
    aws_account = var.aws_account
    aws_region = var.aws_region

    cloudwatch_logs_delivery_full_access_policy-arn = module.iam-logs-delivery-full-access-policy.cloudwatch_logs_delivery_full_access_policy-arn
    sf_mlb_statsapi_etl_runTask_policy-arn = module.iam-sf_mlb_statsapi_etl_runTask-policy.sf_mlb_statsapi_etl_runTask_policy-arn

    mlb_statsapi_sg-id = module.mlb-statsapi-vpc.mlb_statsapi_sg-id
    sn_pub_a0_id = module.mlb-statsapi-vpc.sn_pub_a0_id
    sn_pub_b0_id = module.mlb-statsapi-vpc.sn_pub_b0_id

    ecs_task_definition_mlb_statsapi_etl-arn = module.ecs-mlb-statsapi-etl-task.ecs_task_definition_mlb_statsapi_etl-arn
    ecs_cluster_mlb_statsapi_etl-arn = module.ecs-mlb-statsapi-etl-task.ecs_cluster_mlb_statsapi_etl-arn

    mlb_statsapi_etl_image-repository_name = module.ecr-mlb-statsapi-etl-repository.mlb_statsapi_etl_image-repository_name

    sns_mlb_statsapi_event-arn = module.mlb-statsapi-event-notification.sns_mlb_statsapi_event-arn

    depends_on = [
        module.iam-logs-delivery-full-access-policy,
        module.iam-sf_mlb_statsapi_etl_runTask-policy,
        module.mlb-statsapi-vpc,
        module.ecs-mlb-statsapi-etl-task,
    ]
}


module "lambda-layer-mlb-statsapi" {
    source = "./tf/modules/lambda-layer/mlb-statsapi-layer"

    aws_region = var.aws_region
    env_name = var.env_name
    build_version = module.variables.build
    always_run = local.always_run-lambda-layer-mlb-statsapi

    depends_on = [
        module.variables
    ]
}

module "lambda-sf-pregame-state-set-game" {
    source = "./tf/modules/lambda-function/lambda-sf-pregame-state-set-game"

    aws_region = var.aws_region
    env_name = var.env_name
    always_run = local.always_run-lambda-sf-pregame-state-set-game

    build_version = module.variables.build
    mlb_statsapi_lambda_layer_arn = module.lambda-layer-mlb-statsapi.mlb_statsapi_lambda_layer_arn
    AWSLambdaBasicExecutionRole-arn = module.lambda-layer-mlb-statsapi.AWSLambdaBasicExecutionRole-arn

    depends_on = [
        module.variables,
        module.lambda-layer-mlb-statsapi,
    ]


}


module "lambda-sf-pregame-state-set-team" {
    source = "./tf/modules/lambda-function/lambda-sf-pregame-state-set-team"

    aws_region = var.aws_region
    env_name = var.env_name
    always_run = local.always_run-lambda-sf-pregame-state-set-team

    build_version = module.variables.build
    mlb_statsapi_lambda_layer_arn = module.lambda-layer-mlb-statsapi.mlb_statsapi_lambda_layer_arn
    AWSLambdaBasicExecutionRole-arn = module.lambda-layer-mlb-statsapi.AWSLambdaBasicExecutionRole-arn

    depends_on = [
        module.variables,
        module.lambda-layer-mlb-statsapi
    ]


}


module "sf-mlb-statsapi-season" {
    source = "./tf/modules/stepfunctions/sf-mlb-statsapi-season"

    env_name = var.env_name
    aws_profile = var.aws_profile
    aws_account = var.aws_account
    aws_region = var.aws_region

    cloudwatch_logs_delivery_full_access_policy-arn = module.iam-logs-delivery-full-access-policy.cloudwatch_logs_delivery_full_access_policy-arn

    sns_mlb_statsapi_event-arn = module.mlb-statsapi-event-notification.sns_mlb_statsapi_event-arn
    mlb_statsapi_sns_publish_event_policy-arn = module.mlb-statsapi-event-notification.mlb_statsapi_sns_publish_event_policy-arn

    depends_on = [
        module.iam-logs-delivery-full-access-policy,
        module.mlb-statsapi-event-notification,
    ]
}


module "sf-mlb-statsapi-pregame" {
    source = "./tf/modules/stepfunctions/sf-mlb-statsapi-pregame"

    env_name = var.env_name
    aws_profile = var.aws_profile
    aws_account = var.aws_account
    aws_region = var.aws_region

    cloudwatch_logs_delivery_full_access_policy-arn = module.iam-logs-delivery-full-access-policy.cloudwatch_logs_delivery_full_access_policy-arn

    mlb_statsapi_sns_publish_event_policy-arn = module.mlb-statsapi-event-notification.mlb_statsapi_sns_publish_event_policy-arn
    mlb_statsapi_sns_publish_workflow_policy-arn = module.mlb-statsapi-workflow-notification.mlb_statsapi_sns_publish_workflow_policy-arn

    sns_mlb_statsapi_event-arn = module.mlb-statsapi-event-notification.sns_mlb_statsapi_event-arn
    sns_mlb_statsapi_workflow-arn = module.mlb-statsapi-workflow-notification.sns_mlb_statsapi_workflow-arn

    mlb_statsapi_states_pregame_set_game_lambda-arn = module.lambda-sf-pregame-state-set-game.mlb_statsapi_states_pregame_set_game_lambda-arn
    mlb_statsapi_states_pregame_set_team_lambda-arn = module.lambda-sf-pregame-state-set-team.mlb_statsapi_states_pregame_set_team_lambda-arn
    sf_mlb_statsapi_etl_game-arn = module.sf-mlb-statsapi-game.sf_mlb_statsapi_etl_game-arn

    depends_on = [
        module.iam-logs-delivery-full-access-policy,
        module.mlb-statsapi-event-notification,
        module.mlb-statsapi-workflow-notification,
        module.lambda-sf-pregame-state-set-game,
        module.lambda-sf-pregame-state-set-team,
        module.sf-mlb-statsapi-game
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

    sqs_mlb_statsapi_workflow-id = module.mlb-statsapi-workflow-notification.sqs_mlb_statsapi_workflow-id

    sf_mlb_statsapi_etl_pregame-arn = module.sf-mlb-statsapi-pregame.sf_mlb_statsapi_etl_pregame-arn

    depends_on = [
        module.variables,
        module.lambda-layer-mlb-statsapi,
        module.mlb-statsapi-workflow-notification,
        module.sf-mlb-statsapi-pregame,
    ]
}


module "sf-mlb-statsapi-schedule" {
    source = "./tf/modules/stepfunctions/sf-mlb-statsapi-schedule"

    env_name = var.env_name
    aws_profile = var.aws_profile
    aws_account = var.aws_account
    aws_region = var.aws_region

    cloudwatch_logs_delivery_full_access_policy-arn = module.iam-logs-delivery-full-access-policy.cloudwatch_logs_delivery_full_access_policy-arn
    sf_mlb_statsapi_etl_runTask_policy-arn = module.iam-sf_mlb_statsapi_etl_runTask-policy.sf_mlb_statsapi_etl_runTask_policy-arn

    mlb_statsapi_sg-id = module.mlb-statsapi-vpc.mlb_statsapi_sg-id
    sn_pub_a0_id = module.mlb-statsapi-vpc.sn_pub_a0_id
    sn_pub_b0_id = module.mlb-statsapi-vpc.sn_pub_b0_id

    mlb_statsapi_etl_image-repository_name = module.ecr-mlb-statsapi-etl-repository.mlb_statsapi_etl_image-repository_name

    ecs_task_definition_mlb_statsapi_etl-arn = module.ecs-mlb-statsapi-etl-task.ecs_task_definition_mlb_statsapi_etl-arn
    ecs_cluster_mlb_statsapi_etl-arn = module.ecs-mlb-statsapi-etl-task.ecs_cluster_mlb_statsapi_etl-arn
    ecs_mlb_statsapi_etl-taskRole-arn = module.ecs-mlb-statsapi-etl-task.ecs_mlb_statsapi_etl-taskRole-arn
    ecs_mlb_statsapi_etl-taskExecutionRole-arn = module.ecs-mlb-statsapi-etl-task.ecs_mlb_statsapi_etl-taskExecutionRole-arn

    depends_on = [
        module.iam-logs-delivery-full-access-policy,
        module.iam-sf_mlb_statsapi_etl_runTask-policy,
        module.mlb-statsapi-vpc,
        module.ecr-mlb-statsapi-etl-repository,
        module.ecs-mlb-statsapi-etl-task,
    ]
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
        module.variables,
        module.lambda-layer-mlb-statsapi,
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

    cloudwatch_logs_delivery_full_access_policy-arn = module.iam-logs-delivery-full-access-policy.cloudwatch_logs_delivery_full_access_policy-arn

    sns_mlb_statsapi_workflow-arn = module.mlb-statsapi-workflow-notification.sns_mlb_statsapi_workflow-arn
    mlb_statsapi_sns_publish_workflow_policy-arn = module.mlb-statsapi-workflow-notification.mlb_statsapi_sns_publish_workflow_policy-arn

    depends_on = [
        module.lambda-sf-gameday-state-date-in-season,
        module.lambda-sf-gameday-state-set-scheduled-games,
        module.iam-logs-delivery-full-access-policy,
        module.mlb-statsapi-workflow-notification,
    ]

}
//
//
//module "lambda-sf-gameday-trigger-start-execution" {
//    source = "./tf/modules/lambda-function/lambda-sf-gameday-trigger-start-execution"
//
//    aws_region = var.aws_region
//    env_name = var.env_name
//    build_version = module.variables.build
//    always_run = local.always_run-lambda-sf-gameday-trigger-start-execution
//    mlb_statsapi_lambda_layer_arn = module.lambda-layer-mlb-statsapi.mlb_statsapi_lambda_layer_arn
//
//    sf_mlb_statsapi_etl_gameday = module.sf-mlb-statsapi-gameday.sf_mlb_statsapi_etl_gameday
//    sf_mlb_statsapi_etl_gameday-arn = module.sf-mlb-statsapi-gameday.sf_mlb_statsapi_etl_gameday-arn
//
//    AWSLambdaBasicExecutionRole-arn = module.lambda-layer-mlb-statsapi.AWSLambdaBasicExecutionRole-arn
//
//    depends_on = [
//        module.variables,
//        module.lambda-layer-mlb-statsapi,
//        module.sf-mlb-statsapi-gameday,
//    ]
//}


//module "notifications" {
//    source = "./tf/notifications"
//    env_name = var.env_name
//}


//module "lambda-function-function" {
//    source = "./tf/lambda-function-function"
//    env_name = var.env_name
//    sns_mlb_statsapi_set_scheduled_games_arn = module.notifications.sns_mlb_statsapi_set_scheduled_games_arn
//}


module "lambda-function-run-workflow" {
    source = "./tf/modules/lambda-function/lambda-function-run-workflow"

    aws_region = var.aws_region
    env_name = var.env_name
    aws_account = var.aws_account
    build_version = module.variables.build
    always_run = local.always_run-lambda-function-run-workflow

    mlb_statsapi_lambda_layer_arn = module.lambda-layer-mlb-statsapi.mlb_statsapi_lambda_layer_arn
    AWSLambdaBasicExecutionRole-arn = module.lambda-layer-mlb-statsapi.AWSLambdaBasicExecutionRole-arn

    sf_mlb_statsapi_etl_season-arn = module.sf-mlb-statsapi-season.sf_mlb_statsapi_etl_season-arn
    sf_mlb_statsapi_etl_season-name = module.sf-mlb-statsapi-season.sf_mlb_statsapi_etl_season-name

    sf_mlb_statsapi_etl_gameday-arn = module.sf-mlb-statsapi-gameday.sf_mlb_statsapi_etl_gameday-arn
    sf_mlb_statsapi_etl_gameday-name = module.sf-mlb-statsapi-gameday.sf_mlb_statsapi_etl_gameday-name

    sf_mlb_statsapi_etl_pregame-arn = module.sf-mlb-statsapi-pregame.sf_mlb_statsapi_etl_pregame-arn
    sf_mlb_statsapi_etl_pregame-name = module.sf-mlb-statsapi-pregame.sf_mlb_statsapi_etl_pregame-name

    sf_mlb_statsapi_etl_schedule-name = module.sf-mlb-statsapi-schedule.sf_mlb_statsapi_etl_schedule-name
    sf_mlb_statsapi_etl_schedule-arn = module.sf-mlb-statsapi-schedule.sf_mlb_statsapi_etl_schedule-arn

    sf_mlb_statsapi_etl_game-arn = module.sf-mlb-statsapi-game.sf_mlb_statsapi_etl_game-arn

    sqs_mlb_statsapi_workflow-arn = module.mlb-statsapi-workflow-notification.sqs_mlb_statsapi_workflow-arn
    sqs_mlb_statsapi_workflow-id = module.mlb-statsapi-workflow-notification.sqs_mlb_statsapi_workflow-id
    sqs_mlb_statsapi_workflow-name = module.mlb-statsapi-workflow-notification.sqs_mlb_statsapi_workflow-name

    depends_on = [
        module.mlb-statsapi-workflow-notification,
        module.lambda-layer-mlb-statsapi,
        module.sf-mlb-statsapi-season,
        module.sf-mlb-statsapi-gameday,
        module.sf-mlb-statsapi-pregame,
        module.sf-mlb-statsapi-schedule,
        module.sf-mlb-statsapi-game
    ]
}


module "lambda-function-event-handler" {
    source = "./tf/modules/lambda-function/lambda-function-event-handler"

    aws_region = var.aws_region
    env_name = var.env_name
    aws_account = var.aws_account
    build_version = module.variables.build
    always_run = local.always_run-lambda-function-event-handler

    mlb_statsapi_lambda_layer_arn = module.lambda-layer-mlb-statsapi.mlb_statsapi_lambda_layer_arn
    AWSLambdaBasicExecutionRole-arn = module.lambda-layer-mlb-statsapi.AWSLambdaBasicExecutionRole-arn
    mlb_statsapi_s3_data_bucket_service_policy-arn = module.s3-data-bucket.mlb_statsapi_s3_data_bucket_service_policy-arn

    sqs_mlb_statsapi_event-arn = module.mlb-statsapi-event-notification.sqs_mlb_statsapi_event-arn
    sqs_mlb_statsapi_event-id = module.mlb-statsapi-event-notification.sqs_mlb_statsapi_event-id
    sqs_mlb_statsapi_event-name = module.mlb-statsapi-event-notification.sqs_mlb_statsapi_event-name

    depends_on = [
        module.variables,
        module.lambda-layer-mlb-statsapi,
        module.mlb-statsapi-event-notification,
        module.s3-data-bucket,
    ]
}