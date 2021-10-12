/*
// Endpoints
resource "aws_vpc_endpoint" "vpce_ecr_api_gw_ep" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.mlb_statsapi_sg.id]
  subnet_ids = aws_subnet.public[*].id
  private_dns_enabled = true
  tags = {
    Name = "${local.vpc-name}-vpce-ecr.api-gw-ep"
    Env = var.env_name
  }
}
*/


/*
// not sure if necessary - added while failing to run the ecs task
resource "aws_vpc_endpoint" "vpce_logs_gw_ep" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.logs"
  security_group_ids = [
    aws_security_group.mlb_statsapi_sg.id
  ]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = aws_subnet.public[*].id
  tags = {
    Name = "${local.vpc-name}-vpce-logs-gw-ep"
    Env = var.env_name
  }
}
*/


//resource "aws_vpc_endpoint" "vpce_s3_gw_ep" {
//  vpc_id = aws_vpc.mlb_statsapi_vpc.id
//  service_name = "com.amazonaws.${var.aws_region}.s3"
//  vpc_endpoint_type = "Gateway"
//  policy = <<POLICY
//{
//    "Version": "2012-10-17",
//    "Statement": [
//        {
//            "Effect": "Allow",
//            "Principal": "*",
//            "Action": "s3:*",
//            "Resource": [
//                "arn:aws:s3:::*",
//                "arn:aws:s3:::*/*"
//            ]
//        }
//    ]
//}
//POLICY
//  tags = {
//    Name = "${local.vpc-name}-vpce-s3-gw-ep"
//    Env = var.env_name
//  }
//}




/*
resource "aws_vpc_endpoint" "vpce_ecr_dkr_gw_ep" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.mlb_statsapi_sg.id]
  subnet_ids = aws_subnet.public[*].id
  private_dns_enabled = true

  depends_on = [
    aws_vpc.mlb_statsapi_vpc,
    aws_security_group.mlb_statsapi_sg,
    aws_subnet.public,
  ]
  tags = {
    Name = "${local.vpc-name}-vpce-ecr.dkr-gw-ep"
    Env = var.env_name
  }
}
*/

