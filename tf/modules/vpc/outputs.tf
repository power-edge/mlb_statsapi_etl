
// Output - VPC Id
output "vpc_id" {
  value = aws_vpc.mlb_statsapi_vpc.id
}

// Output - Security Group Id
output "mlb_statsapi_sg-id" {
  value = aws_security_group.mlb_statsapi_sg.id
}

/*
// Output - Private Subnet Ids
output "subnet-private-ids" {
  value = aws_subnet.private[*].id
}
*/
// Output - Private Subnet Ids
output "subnet-public-ids" {
  value = aws_subnet.public[*].id
}
