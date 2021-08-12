variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}
variable "env_name" {}

variable "run-ecr-mlb-statsapi-etl-build" {}
variable "run-ecr-mlb-statsapi-etl-push" {}
variable "build_version" {}

variable "mlb_statsapi_etl_image-repository_name" {}

variable "mlb_statsapi_s3_data_bucket_service_policy-arn" {}


locals {
  repository_name = "mlb-statsapi-etl"
}

resource "aws_ecs_cluster" "ecs_cluster_mlb_statsapi_etl" {
  name = var.mlb_statsapi_etl_image-repository_name


  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = var.mlb_statsapi_etl_image-repository_name
    Env = var.env_name
  }
}

output "ecs_cluster_mlb_statsapi_etl-arn" {
  value = aws_ecs_cluster.ecs_cluster_mlb_statsapi_etl.arn
}

resource "aws_cloudwatch_log_group" "ecs_cluster_mlb_statsapi_etl-Logs" {
  //noinspection HILUnresolvedReference
  name = "/ecs/${aws_ecs_cluster.ecs_cluster_mlb_statsapi_etl.name}"
  retention_in_days = 7
}


resource "aws_iam_role" "ecs_mlb_statsapi_etl-taskRole" {
  name = "tf-ecs_mlb_statsapi_etl-taskRole-${var.aws_region}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach-ecs_mlb_statsapi_etl-taskRole__mlb_statsapi_s3_data_bucket_service_policy" {
  policy_arn = var.mlb_statsapi_s3_data_bucket_service_policy-arn
  role = aws_iam_role.ecs_mlb_statsapi_etl-taskRole.name
  depends_on = [
    aws_iam_role.ecs_mlb_statsapi_etl-taskRole
  ]
}


data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role_policy_attachment" "attachAmazonECSTaskExecutionRolePolicy" {
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
  role = aws_iam_role.ecs_mlb_statsapi_etl-taskExecutionRole.name
  depends_on = [
    data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy,
    aws_iam_role.ecs_mlb_statsapi_etl-taskExecutionRole
  ]
}


resource "aws_iam_role" "ecs_mlb_statsapi_etl-taskExecutionRole" {
  name = "tf-ecs_mlb_statsapi_etl-taskExecutionRole-${var.aws_region}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_mlb_statsapi_etl-taskPolicy-states" {
  name = "tf-ecs_mlb_statsapi_etl-taskPolicy-states-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "states:SendTaskSuccess",
        "states:SendTaskFailure",
        "states:SendTaskHeartbeat"
      ]
      Resource = "*"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "attach-ecs_mlb_statsapi_etl-taskPolicy-states" {
  policy_arn = aws_iam_policy.ecs_mlb_statsapi_etl-taskPolicy-states.arn
  role = aws_iam_role.ecs_mlb_statsapi_etl-taskRole.name
  depends_on = [
    aws_iam_role.ecs_mlb_statsapi_etl-taskRole,
    aws_iam_policy.ecs_mlb_statsapi_etl-taskPolicy-states
  ]
}


resource "aws_iam_policy" "ecs_mlb_statsapi_etl-taskExecutionRole-policy" {
  name = "ecs_mlb_statsapi_etl-taskExecutionRole-policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:*",
          "secretsmanager:*",
          "ssm:*",
          "s3:*",
          "ecr:*",
          "ecs:*",
          "ec2:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account}:secret:*",
          "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach-ecs_mlb_statsapi_etl-taskExecutionRole-policy" {
  policy_arn = aws_iam_policy.ecs_mlb_statsapi_etl-taskExecutionRole-policy.arn
  role = aws_iam_role.ecs_mlb_statsapi_etl-taskExecutionRole.name
  depends_on = [
    aws_iam_policy.ecs_mlb_statsapi_etl-taskExecutionRole-policy,
    aws_iam_role.ecs_mlb_statsapi_etl-taskExecutionRole
  ]
}


resource "aws_ecs_task_definition" "ecs_task_definition_mlb_statsapi_etl" {
  container_definitions = <<DEFINITION
[{
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "/ecs/${var.mlb_statsapi_etl_image-repository_name}",
      "awslogs-region": "${var.aws_region}",
      "awslogs-stream-prefix": "ecs"
    }
  },
  "portMappings": [],
  "cpu": 512,
  "memory": 1024,
  "memoryReservation": 512,
  "environment": [],
  "volumesFrom": [],
  "image": "${var.aws_account}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.mlb_statsapi_etl_image-repository_name}:${var.build_version}",
  "essential": true,
  "name": "${var.mlb_statsapi_etl_image-repository_name}"
}]
  DEFINITION
  family = var.mlb_statsapi_etl_image-repository_name
  //noinspection HILUnresolvedReference
  execution_role_arn = aws_iam_role.ecs_mlb_statsapi_etl-taskExecutionRole.arn
  memory = 1024
  //noinspection HILUnresolvedReference
  task_role_arn = aws_iam_role.ecs_mlb_statsapi_etl-taskRole.arn
  requires_compatibilities = [
    "FARGATE"
  ]
  network_mode = "awsvpc"
  cpu = 512
  depends_on = [
    aws_iam_role.ecs_mlb_statsapi_etl-taskExecutionRole,
    aws_iam_role.ecs_mlb_statsapi_etl-taskRole
  ]
}

output "ecs_task_definition_mlb_statsapi_etl-arn" {
  value = aws_ecs_task_definition.ecs_task_definition_mlb_statsapi_etl.arn
}

output "ecs_mlb_statsapi_etl-taskExecutionRole-arn" {
  value = aws_iam_role.ecs_mlb_statsapi_etl-taskExecutionRole.arn
}

output "ecs_mlb_statsapi_etl-taskRole-arn" {
  value = aws_iam_role.ecs_mlb_statsapi_etl-taskRole.arn
}


