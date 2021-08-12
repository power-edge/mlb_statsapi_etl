//variable "aws_profile" {}
//variable "aws_account" {}
//variable "aws_region" {}
//variable "env_name" {}
//
//
//resource "aws_dynamodb_table" "dynamodb-mlb-statsapi-gameday-table" {
//  name = "${var.env_name}"
//  billing_mode = "PROVISIONED"
//  read_capacity = 42
//  write_capacity = 42
//  hash_key = "hash_key"
////  range_key = "hash_key"
//  stream_enabled = false
//
//  server_side_encryption {
//    enabled = false
//  }
//
//  attribute {
//    name = "hash_key"
//    type = "S"
//  }
//
//  tags = {
//    Name = "${var.env_name}-gameday"
//    Env = var.env_name
//  }
//}
//
//output "dynamodb-mlb-statsapi-gameday-table-name" {
//  value = aws_dynamodb_table.dynamodb-mlb-statsapi-gameday-table.name
//}
//
//output "dynamodb-mlb-statsapi-gameday-table-arn" {
//  value = aws_dynamodb_table.dynamodb-mlb-statsapi-gameday-table.arn
//}
//
//output "dynamodb-mlb-statsapi-gameday-table-id" {
//  value = aws_dynamodb_table.dynamodb-mlb-statsapi-gameday-table.id
//}
