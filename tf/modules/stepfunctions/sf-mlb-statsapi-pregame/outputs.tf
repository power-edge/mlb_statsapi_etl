output "sf_mlb_statsapi_etl_pregame-arn" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_pregame.arn
}

output "sf_mlb_statsapi_etl_pregame-name" {
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_pregame.name
}
