variable "env" {
    type = string
    default = "dev"
    validation {
        condition = can(regex("[dev|qa|prod]", var.env))
        error_message = "The env must be (dev,qa,prod)."
    }
}



// VPC
resource "aws_vpc" "mlb_statsapi_vpc" {
  cidr_block = "10.1.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "mlb_statsapi_vpc"
  }
}


// SECURITY GROUP
resource "aws_security_group" "mlb_statsapi_sg" {
  name        = "mlb_statsapi_sg"
  description = "Allow All inbound traffic"
  vpc_id      = aws_vpc.mlb_statsapi_vpc.id

  ingress {
    description      = "All from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.mlb_statsapi_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mlb_statsapi_sg"
  }
}


// Subnets - PRIVATE
resource "aws_subnet" "sn_prv_us_west_1a_00" {
  vpc_id     = aws_vpc.mlb_statsapi_vpc.id
  //noinspection HILUnresolvedReference
  cidr_block = var.cidr_block.sn_prv_us_west_1a_00

  availability_zone = "us-west-1a"

  tags = {
    Name = "mlb-statsapi-${var.env}-prv-sn-us-west-1a-00"
  }
}

resource "aws_subnet" "sn_prv_us_west_1b_00" {
  vpc_id     = aws_vpc.mlb_statsapi_vpc.id
  cidr_block = var.cidr_block.sn_prv_us_west_1b_00

  availability_zone = "us-west-1b"

  tags = {
    Name = "mlb-statsapi-${var.env}-prv-sn-us-west-1b-00"
  }
}


// Subnets - PUBLIC
resource "aws_subnet" "sn_pub_us_west_1a_00" {
  vpc_id     = aws_vpc.mlb_statsapi_vpc.id
  //noinspection HILUnresolvedReference
  cidr_block = var.cidr_block.sn_pub_us_west_1a_00

  availability_zone = "us-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-pub-sn-us-west-1a-00"
  }
}

resource "aws_subnet" "sn_pub_us_west_1b_00" {
  vpc_id     = aws_vpc.mlb_statsapi_vpc.id
  //noinspection HILUnresolvedReference
  cidr_block = var.cidr_block.sn_pub_us_west_1b_00

  availability_zone = "us-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-pub-sn-us-west-1b-00"
  }
}


// ROUTE TABLES
resource "aws_route_table" "rtb_prv_0" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id
//  Error: error creating Route in Route Table (rtb-08675a85136960612) with destination (0.0.0.0/0):
//    RouteAlreadyExists: The route identified by 0.0.0.0/0 already exists.
//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = aws_nat_gateway.nat_gw_prv_us_west_1b_00.id
//  }
//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = aws_nat_gateway.nat_gw_prv_us_west_1d_00.id
//  }

  tags = {
    Name = "${var.env}-rt-prv-0"
  }
}


//resource "aws_route" "route_rtb_prv_0a" {
//  route_table_id = aws_route_table.rtb_prv_0.id
//  destination_cidr_block = "0.0.0.0/0"
//  gateway_id = aws_nat_gateway.nat_gw_prv_us_west_1a_00.id
//}
//
//resource "aws_route_table" "rtb_pub_0" {
//  vpc_id = aws_vpc.vpc.id
//  tags = {
//    Name = "${local.vpc-nm}-rt-pub-0"
//    email = var.email
//  }
//}
//resource "aws_route" "route_rtb_pub_0a" {
//  route_table_id = aws_route_table.rtb_pub_0.id
//  destination_cidr_block = "0.0.0.0/0"
//  gateway_id = aws_internet_gateway.igw.id
//  depends_on = [aws_internet_gateway.igw]
//}
//
//
//// ROUTE TABLE ASSOCIATIONS - PRIVATE
//resource "aws_route_table_association" "rta_prv_us_west_1a_00"{
//  subnet_id = aws_subnet.sn_prv_us_west_1a_00.id
//  route_table_id = aws_route_table.rtb_prv_0.id
//}
//resource "aws_route_table_association" "rta_prv_us_west_1b_00"{
//  subnet_id = aws_subnet.sn_prv_us_west_1b_00.id
//  route_table_id = aws_route_table.rtb_prv_0.id
//}
////resource "aws_route_table_association" "rta_prv_us_west_1d_00"{
////  subnet_id = aws_subnet.sn_prv_us_west_1d_00.id
////  route_table_id = aws_route_table.rtb_prv_0.id
////}
//
//// ROUTE TABLE ASSOCIATIONS - PUBLIC
//resource "aws_route_table_association" "rta_pub_us_west_1a_00"{
//  subnet_id = aws_subnet.sn_pub_us_west_1a_00.id
//  route_table_id = aws_route_table.rtb_pub_0.id
//}
//resource "aws_route_table_association" "rta_pub_us_west_1b_00"{
//  subnet_id = aws_subnet.sn_pub_us_west_1b_00.id
//  route_table_id = aws_route_table.rtb_pub_0.id
//}
////resource "aws_route_table_association" "rta_pub_us_west_1d_00"{
////  subnet_id = aws_subnet.sn_pub_us_west_1d_00.id
////  route_table_id = aws_route_table.rtb_pub_0.id
////}
//
//
//// IGW
//resource "aws_internet_gateway" "igw" {
//  vpc_id = aws_vpc.vpc.id
//
//  tags = {
//    Name = "${local.vpc-nm}-igw"
//    email = var.email
//  }
//}
//
//
//// Elastic IPs - PRIVATE
//resource "aws_eip" "nat_eip_prv_us_west_1a_00" {
//  vpc = true
//  tags = {
//    Name = "${local.vpc-nm}-eip-prv-us-west-1a-00"
//    email = var.email
//  }
//  depends_on = [aws_internet_gateway.igw]
//}
//
//resource "aws_eip" "nat_eip_prv_us_west_1b_00" {
//  vpc = true
//  tags = {
//    Name = "${local.vpc-nm}-eip-prv-us-west-1b-00"
//    email = var.email
//  }
//  depends_on = [aws_internet_gateway.igw]
//}
//
////resource "aws_eip" "nat_eip_prv_us_west_1d_00" {
////  vpc = true
////  tags = {
////    Name = "${local.vpc-nm}-eip-prv-us-west-1d-00"
////    email = var.email
////  }
////  depends_on = [aws_internet_gateway.igw]
////}
//
//
//// Elastic IPs - PUBLIC
//resource "aws_eip" "nat_eip_pub_us_west_1a_00" {
//  vpc = true
//  tags = {
//    Name = "${local.vpc-nm}-eip-pub-us-west-1a-00"
//    email = var.email
//  }
//  depends_on = [aws_internet_gateway.igw]
//}
//
//resource "aws_eip" "nat_eip_pub_us_west_1b_00" {
//  vpc = true
//  tags = {
//    Name = "${local.vpc-nm}-eip-pub-us-west-1b-00"
//    email = var.email
//  }
//  depends_on = [aws_internet_gateway.igw]
//}
//
////resource "aws_eip" "nat_eip_pub_us_west_1d_00" {
////  vpc = true
////  tags = {
////    Name = "${local.vpc-nm}-eip-pub-us-west-1d-00"
////    email = var.email
////  }
////  depends_on = [aws_internet_gateway.igw]
////}
//
//
//// NAT Gateway - PRIVATE
//resource "aws_nat_gateway" "nat_gw_prv_us_west_1a_00" {
//  allocation_id = aws_eip.nat_eip_prv_us_west_1a_00.id
//  subnet_id     = aws_subnet.sn_prv_us_west_1a_00.id
//
//  tags = {
//    Name = "${local.vpc-nm}-nat-gw-prv-us-west-1a-00"
//    email = var.email
//  }
//  # To ensure proper ordering, it is recommended to add an explicit dependency on the igw
//  depends_on = [aws_internet_gateway.igw]
//}
//
//resource "aws_nat_gateway" "nat_gw_prv_us_west_1b_00" {
//  allocation_id = aws_eip.nat_eip_prv_us_west_1b_00.id
//  subnet_id     = aws_subnet.sn_prv_us_west_1b_00.id
//
//  tags = {
//    Name = "${local.vpc-nm}-nat-gw-prv-us-west-1b-00"
//    email = var.email
//  }
//  depends_on = [aws_internet_gateway.igw]
//}
//
////resource "aws_nat_gateway" "nat_gw_prv_us_west_1d_00" {
////  allocation_id = aws_eip.nat_eip_prv_us_west_1d_00.id
////  subnet_id     = aws_subnet.sn_prv_us_west_1d_00.id
////
////  tags = {
////    Name = "${local.vpc-nm}-nat-gw-prv-us-west-1d-00"
////    email = var.email
////  }
////  depends_on = [aws_internet_gateway.igw]
////}
//
//// NAT Gateway - PUBLIC
//resource "aws_nat_gateway" "nat_gw_pub_us_west_1a_00" {
//  allocation_id = aws_eip.nat_eip_pub_us_west_1a_00.id
//  subnet_id     = aws_subnet.sn_pub_us_west_1a_00.id
//
//  tags = {
//    Name = "${local.vpc-nm}-nat-gw-pub-us-west-1a-00"
//    email = var.email
//  }
//  depends_on = [aws_internet_gateway.igw]
//}
//
//resource "aws_nat_gateway" "nat_gw_pub_us_west_1b_00" {
//  allocation_id = aws_eip.nat_eip_pub_us_west_1b_00.id
//  subnet_id     = aws_subnet.sn_pub_us_west_1b_00.id
//
//  tags = {
//    Name = "${local.vpc-nm}-nat-gw-pub-us-west-1b-00"
//    email = var.email
//  }
//  depends_on = [aws_internet_gateway.igw]
//}
//
////resource "aws_nat_gateway" "nat_gw_pub_us_west_1d_00" {
////  allocation_id = aws_eip.nat_eip_pub_us_west_1d_00.id
////  subnet_id     = aws_subnet.sn_pub_us_west_1d_00.id
////
////  tags = {
////    Name = "${local.vpc-nm}-nat-gw-pub-us-west-1d-00"
////    email = var.email
////  }
////  depends_on = [aws_internet_gateway.igw]
////}
//
//
//// Endpoints
//resource "aws_vpc_endpoint" "vpce_ecr_api_gw_ep" {
//  vpc_id = aws_vpc.vpc.id
//  service_name = "com.amazonaws.us-west-1.ecr.api"
//  vpc_endpoint_type = "Interface"
//  security_group_ids = [aws_security_group.sg.id]
//  subnet_ids = [
//    aws_subnet.sn_prv_us_west_1a_00.id,
//    aws_subnet.sn_prv_us_west_1b_00.id,
////    aws_subnet.sn_prv_us_west_1d_00.id
//  ]
//  private_dns_enabled = true
//  tags = {
//    Name = "${local.vpc-nm}-vpce-ecr.api-gw-ep"
//    email = var.email
//  }
//}
//
//resource "aws_vpc_endpoint" "vpce_sns_gw_ep" {
//  vpc_id = aws_vpc.vpc.id
//  service_name = "com.amazonaws.us-west-1.sns"
//  vpc_endpoint_type = "Interface"
//  security_group_ids = [aws_security_group.sg.id]
//  subnet_ids = [
//    aws_subnet.sn_prv_us_west_1a_00.id,
//    aws_subnet.sn_prv_us_west_1b_00.id,
////    aws_subnet.sn_prv_us_west_1d_00.id
//  ]
//  private_dns_enabled = true
//  tags = {
//    Name = "${local.vpc-nm}-vpce-sns-gw-ep"
//    email = var.email
//  }
//}
//resource "aws_vpc_endpoint" "vpce_ecr_dkr_gw_ep" {
//  vpc_id = aws_vpc.vpc.id
//  service_name = "com.amazonaws.us-west-1.ecr.dkr"
//  vpc_endpoint_type = "Interface"
//  security_group_ids = [aws_security_group.sg.id]
//  subnet_ids = [
//    aws_subnet.sn_prv_us_west_1a_00.id,
//    aws_subnet.sn_prv_us_west_1b_00.id,
////    aws_subnet.sn_prv_us_west_1d_00.id
//  ]
//  private_dns_enabled = true
//  tags = {
//    Name = "${local.vpc-nm}-vpce-ecr.dkr-gw-ep"
//    email = var.email
//  }
//}
//resource "aws_vpc_endpoint" "vpce_lambda_gw_ep" {
//  vpc_id = aws_vpc.vpc.id
//  service_name = "com.amazonaws.us-west-1.lambda"
//  vpc_endpoint_type = "Interface"
//
//  security_group_ids = [aws_security_group.sg.id]
//  subnet_ids = [
//    aws_subnet.sn_prv_us_west_1a_00.id,
//    aws_subnet.sn_prv_us_west_1b_00.id,
////    aws_subnet.sn_prv_us_west_1d_00.id
//  ]
//  private_dns_enabled = true
//  tags = {
//    Name = "${local.vpc-nm}-vpce-lambda-gw-ep"
//    email = var.email
//  }
//}
//resource "aws_vpc_endpoint" "vpce_s3_gw_ep" {
//  vpc_id = aws_vpc.vpc.id
//  service_name = "com.amazonaws.us-west-1.s3"
//  vpc_endpoint_type = "Gateway"
//  policy = <<POLICY
//{
//    "Version": "2012-10-17",
//    "Id": "Policy1623089889886",
//    "Statement": [
//        {
//            "Sid": "Stmt1623089888955",
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
//    Name = "${local.vpc-nm}-vpce-s3-gw-ep"
//    email = var.email
//  }
//}
//
//resource "aws_vpc_endpoint" "vpce_states_gw_ep" {
//  vpc_id = aws_vpc.vpc.id
//  service_name = "com.amazonaws.us-west-1.states"
//  security_group_ids = [aws_security_group.sg.id]
//  vpc_endpoint_type = "Interface"
//  private_dns_enabled = true
//  tags = {
//    Name = "${local.vpc-nm}-vpce-states-gw-ep"
//    email = var.email
//  }
//}
//
//
//resource "aws_network_acl" "net_acl" {
//  vpc_id = aws_vpc.vpc.id
//  subnet_ids = [
//    aws_subnet.sn_prv_us_west_1a_00.id,
//    aws_subnet.sn_prv_us_west_1b_00.id,
////    aws_subnet.sn_prv_us_west_1d_00.id
//  ]
//  ingress {
//    action = "deny"
//    protocol = -1
//    rule_no = 1
//    from_port = 0
//    to_port = 0
//    cidr_block = aws_vpc.vpc.cidr_block
//  }
//  egress {
//    action = "deny"
//    protocol = -1
//    rule_no = 1
//    from_port = 0
//    to_port = 0
//    cidr_block = aws_vpc.vpc.cidr_block
//  }
//  tags = {
//    Name = "${local.vpc-nm}-net-acl"
//    email = var.email
//  }
//}
//
//// Output - VPC Id
//output "vpc_id" {
//  value = aws_vpc.vpc.id
//}
//
//// Output - Security Group Id
//output "sg_id" {
//  value = aws_security_group.sg.id
//}
//
//// Output - Private Subnet Ids
//output "sn_prv_us_west_1a_00_id" {
//  value = aws_subnet.sn_prv_us_west_1a_00.id
//}
//output "sn_prv_us_west_1b_00_id" {
//  value = aws_subnet.sn_prv_us_west_1b_00.id
//}
////output "sn_prv_us_west_1d_00_id" {
////  value = aws_subnet.sn_prv_us_west_1d_00.id
////}
//
//// Output - Public Subnet Is
//output "sn_pub_us_west_1a_00_id" {
//  value = aws_subnet.sn_pub_us_west_1a_00.id
//}
//output "sn_pub_us_west_1b_00_id" {
//  value = aws_subnet.sn_pub_us_west_1b_00.id
//}
////output "sn_pub_us_west_1d_00_id" {
////  value = aws_subnet.sn_pub_us_west_1d_00.id
////}
//
//// Output - aws_route_table and aws_route_table_association skipped
//
//// Output - Internet Gateway
//output "igw_id" {
//  value = aws_internet_gateway.igw.id
//}
//
//// Output - NAT EIP (Private)
//output "nat_eip_prv_us_west_1a_00_id" {
//  value = aws_eip.nat_eip_prv_us_west_1a_00.id
//}
//output "nat_eip_prv_us_west_1b_00_id" {
//  value = aws_eip.nat_eip_prv_us_west_1b_00.id
//}
////output "nat_eip_prv_us_west_1d_00_id" {
////  value = aws_eip.nat_eip_prv_us_west_1d_00.id
////}
//// Output - NAT EIP (Public)
//output "nat_eip_pub_us_west_1a_00_id" {
//  value = aws_eip.nat_eip_pub_us_west_1a_00.id
//}
//output "nat_eip_pub_us_west_1b_00_id" {
//  value = aws_eip.nat_eip_pub_us_west_1b_00.id
//}
////output "nat_eip_pub_us_west_1d_00_id" {
////  value = aws_eip.nat_eip_pub_us_west_1d_00.id
////}
//
//// Output - NAT Gateway (Private)
//output "nat_gw_prv_us_west_1a_00_id" {
//  value = aws_nat_gateway.nat_gw_prv_us_west_1a_00.id
//}
//output "nat_gw_prv_us_west_1b_00_id" {
//  value = aws_nat_gateway.nat_gw_prv_us_west_1b_00.id
//}
////output "nat_gw_prv_us_west_1d_00_id" {
////  value = aws_nat_gateway.nat_gw_prv_us_west_1d_00.id
////}
//// Output - NAT Gateway (Private)
//output "nat_gw_pub_us_west_1a_00_id" {
//  value = aws_nat_gateway.nat_gw_pub_us_west_1a_00.id
//}
//output "nat_gw_pub_us_west_1b_00_id" {
//  value = aws_nat_gateway.nat_gw_pub_us_west_1b_00.id
//}
////output "nat_gw_pub_us_west_1d_00_id" {
////  value = aws_nat_gateway.nat_gw_pub_us_west_1d_00.id
////}
//
//// Output - VPC Endpoint Id
//output "vpce_ecr_api_gw_ep_id" {
//  value = aws_vpc_endpoint.vpce_ecr_api_gw_ep.id
//}
//output "vpce_sns_gw_ep_id" {
//  value = aws_vpc_endpoint.vpce_sns_gw_ep.id
//}
//output "vpce_ecr_dkr_gw_ep_id" {
//  value = aws_vpc_endpoint.vpce_ecr_dkr_gw_ep.id
//}
//output "vpce_lambda_gw_ep_id" {
//  value = aws_vpc_endpoint.vpce_lambda_gw_ep.id
//}
//output "vpce_s3_gw_ep_id" {
//  value = aws_vpc_endpoint.vpce_s3_gw_ep.id
//}
//output "vpce_states_gw_ep_id" {
//  value = aws_vpc_endpoint.vpce_states_gw_ep.id
//}
//
//// Output Network ACL - Skipping
//
//
//
//
//
//
