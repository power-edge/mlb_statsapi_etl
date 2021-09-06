output "sf_mlb_statsapi_etl_game-arn" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_game.arn
}

output "sf_mlb_statsapi_etl_game-name" {
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_game.name
}
