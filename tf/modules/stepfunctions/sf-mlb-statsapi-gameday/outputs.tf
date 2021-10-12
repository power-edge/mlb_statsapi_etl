output "sf_mlb_statsapi_etl_gameday" {
  value = local.sf_mlb_statsapi_etl_gameday
}

output "sf_mlb_statsapi_etl_gameday-arn" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_gameday.arn
}

output "sf_mlb_statsapi_etl_gameday-name" {
  //noinspection HILUnresolvedReference
  value = aws_sfn_state_machine.sf_mlb_statsapi_etl_gameday.name
}