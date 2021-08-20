variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}
variable "env_name" {}

variable "cloudwatch_logs_delivery_full_access_policy-arn" {}
variable "sns_mlb_statsapi_event-arn" {}
variable "sns_mlb_statsapi_workflow-arn" {}

variable "mlb_statsapi_sns_publish_event_policy-arn" {}
variable "mlb_statsapi_sns_publish_workflow_policy-arn" {}
variable "mlb_statsapi_states_pregame_set_game_lambda-arn" {}
variable "mlb_statsapi_states_pregame_set_team_lambda-arn" {}

variable "sf_mlb_statsapi_etl_game-arn" {}


locals {
  sf_mlb_statsapi_etl_pregame = "mlb_statsapi_etl_pregame"
}


resource "aws_iam_role" "sf_mlb_statsapi_etl_pregame_role" {
  name = "sfn-${local.sf_mlb_statsapi_etl_pregame}-role-${var.aws_region}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_pregame_role__cloudwatch_logs_delivery_full_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.cloudwatch_logs_delivery_full_access_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.name
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_pregame_role__mlb_statsapi_sns_publish_event_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.mlb_statsapi_sns_publish_event_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.name
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_pregame_role__mlb_statsapi_sns_publish_workflow_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = var.mlb_statsapi_sns_publish_workflow_policy-arn
  role = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.name
}


resource "aws_iam_policy" "pregame_invoke_lambda_scoped_access_policy" {
  name = "pregame_invoke_lambda_scoped_access_policy-${var.aws_region}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          var.mlb_statsapi_states_pregame_set_game_lambda-arn,
          var.mlb_statsapi_states_pregame_set_team_lambda-arn
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sf_mlb_statsapi_etl_pregame_role__pregame_invoke_lambda_scoped_access_policy" {
  //noinspection HILUnresolvedReference
  policy_arn = aws_iam_policy.pregame_invoke_lambda_scoped_access_policy.arn
  role = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.name
}


resource "aws_cloudwatch_log_group" "sf_mlb_statsapi_etl_pregame_logs" {
  name = "/aws/vendedlogs/states/${local.sf_mlb_statsapi_etl_pregame}"
  retention_in_days = 3
}


resource "aws_sfn_state_machine" "sf_mlb_statsapi_etl_pregame" {
  name = local.sf_mlb_statsapi_etl_pregame
  //noinspection HILUnresolvedReference
  role_arn = aws_iam_role.sf_mlb_statsapi_etl_pregame_role.arn

  definition = <<DEFINITION
{
  "Comment": "State Machine ${local.sf_mlb_statsapi_etl_pregame} handles the workflow for a give pregame and gameDate.",
  "StartAt": "set-pregame",
  "States": {
    "set-pregame": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "set_game",
          "States": {
            "set_game": {
              "Type": "Task",
              "Resource": "${var.mlb_statsapi_states_pregame_set_game_lambda-arn}",
              "Parameters": {
                "game.$": "$.game"
              },
              "ResultPath": "$.set_game",
              "Next": "notify-team-and-official-events"
            },
            "notify-team-and-official-events": {
              "Type": "Parallel",
              "End": true,
              "Branches": [
                {
                  "StartAt": "notify-team-events",
                  "States": {
                    "notify-team-events": {
                      "Type": "Map",
                      "ItemsPath": "$.set_game.teams",
                      "Parameters": {
                        "message.$": "$$.Map.Item.Value"
                      },
                      "Iterator": {
                        "StartAt": "notify-team-event",
                        "States": {
                          "notify-team-event": {
                            "Type": "Task",
                            "Resource": "arn:aws:states:::sns:publish",
                            "Parameters": {
                              "TopicArn": "${var.sns_mlb_statsapi_event-arn}",
                              "Message.$": "States.JsonToString($.message)",
                              "MessageAttributes": {
                                "Sport": {
                                  "DataType": "String",
                                  "StringValue": "MLB"
                                }
                              }
                            },
                            "End": true
                          }
                        }
                      },
                      "End": true
                    }
                  }
                },
                {
                  "StartAt": "notify-official-events",
                  "States": {
                    "notify-official-events": {
                      "Type": "Map",
                      "ItemsPath": "$.set_game.officials",
                      "Parameters": {
                        "message.$": "$$.Map.Item.Value"
                      },
                      "Iterator": {
                        "StartAt": "notify-official-event",
                        "States": {
                          "notify-official-event": {
                            "Type": "Task",
                            "Resource": "arn:aws:states:::sns:publish",
                            "Parameters": {
                              "TopicArn": "${var.sns_mlb_statsapi_event-arn}",
                              "Message.$": "States.JsonToString($.message)",
                              "MessageAttributes": {
                                "Sport": {
                                  "DataType": "String",
                                  "StringValue": "MLB"
                                }
                              }
                            },
                            "End": true
                          }
                        }
                      },
                      "End": true
                    }
                  }
                }
              ]
            }
          }
        },
        {
          "StartAt": "set_team",
          "States": {
            "set_team": {
              "Type": "Task",
              "Resource": "${var.mlb_statsapi_states_pregame_set_team_lambda-arn}",
              "Parameters": {
                "game.$": "$.game"
              },
              "ResultPath": "$.set_team",
              "Next": "notify-player-events"
            },
            "notify-player-events": {
              "Type": "Map",
              "ItemsPath": "$.set_team.players",
              "Parameters": {
                "message.$": "$$.Map.Item.Value"
              },
              "Iterator": {
                "StartAt": "notify-player-event",
                "States": {
                  "notify-player-event": {
                    "Type": "Task",
                    "Resource": "arn:aws:states:::sns:publish",
                    "Parameters": {
                      "TopicArn": "${var.sns_mlb_statsapi_event-arn}",
                      "Message.$": "States.JsonToString($.message)",
                      "MessageAttributes": {
                        "Sport": {
                          "DataType": "String",
                          "StringValue": "MLB"
                        }
                      }
                    },
                    "End": true
                  }
                }
              },
              "End": true
            }
          }
        },
        {
          "StartAt": "game-workflow-notification",
          "States": {
            "game-workflow-notification": {
              "Type": "Task",
              "Resource": "arn:aws:states:::sns:publish",
              "Parameters": {
                "TopicArn": "${var.sns_mlb_statsapi_workflow-arn}",
                "Message.$": "States.JsonToString($.game)",
                "MessageAttributes": {
                  "Sport": {
                    "DataType": "String",
                    "StringValue": "MLB"
                  },
                  "Workflow": {
                    "DataType": "String",
                    "StringValue": "${var.sf_mlb_statsapi_etl_game-arn}"
                  }
                }
              },
              "End": true
            }
          }
        }
      ],
      "ResultPath": "$.pregame",
      "End": true
    }
  }
}
DEFINITION


  logging_configuration {
    //noinspection HILUnresolvedReference
    log_destination = "${aws_cloudwatch_log_group.sf_mlb_statsapi_etl_pregame_logs.arn}:*"
    include_execution_data = true
    level = "ERROR"
  }
  depends_on = [
    aws_iam_role.sf_mlb_statsapi_etl_pregame_role,
    aws_iam_role_policy_attachment.sf_mlb_statsapi_etl_pregame_role__cloudwatch_logs_delivery_full_access_policy,
    aws_cloudwatch_log_group.sf_mlb_statsapi_etl_pregame_logs
  ]
}


output "sf_mlb_statsapi_etl_pregame-arn" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_pregame.arn
}

output "sf_mlb_statsapi_etl_pregame-name" {
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_pregame.name
}
