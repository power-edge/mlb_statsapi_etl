variable "env_name" {}
variable "aws_profile" {}
variable "aws_account" {}
variable "aws_region" {}

variable "vpc_cidr_block" {}
variable "sn_prv_a0_cidr_block" {}
variable "sn_prv_b0_cidr_block" {}
variable "sn_pub_a0_cidr_block" {}
variable "sn_pub_b0_cidr_block" {}


locals {
  vpc-name = "mlb_statsapi_vpc"
}

// VPC
resource "aws_vpc" "mlb_statsapi_vpc" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = local.vpc-name
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
resource "aws_subnet" "sn_prv_a0" {
  vpc_id     = aws_vpc.mlb_statsapi_vpc.id
  //noinspection HILUnresolvedReference
  cidr_block = var.sn_prv_a0_cidr_block

  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.env_name}-prv-sn-a0"
  }
}

resource "aws_subnet" "sn_prv_b0" {
  vpc_id     = aws_vpc.mlb_statsapi_vpc.id
  cidr_block = var.sn_prv_b0_cidr_block

  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.env_name}-prv-sn-b0"
  }
}


// Subnets - PUBLIC
resource "aws_subnet" "sn_pub_a0" {
  vpc_id     = aws_vpc.mlb_statsapi_vpc.id
  //noinspection HILUnresolvedReference
  cidr_block = var.sn_pub_a0_cidr_block

  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.env_name}-pub-sn-a0"
  }
}

resource "aws_subnet" "sn_pub_b0" {
  vpc_id     = aws_vpc.mlb_statsapi_vpc.id
  //noinspection HILUnresolvedReference
  cidr_block = var.sn_pub_b0_cidr_block

  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env_name}-pub-sn-b0"
  }
}


// ROUTE TABLES
resource "aws_route_table" "rtb_prv_0" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id

//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = aws_nat_gateway.nat_gw_prv_a0.id
//  }

  tags = {
    Name = "${var.env_name}-rt-prv-0"
  }
}


resource "aws_route_table" "rtb_pub_0" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.env_name}-rt-pub-0"
  }

  depends_on = [
    aws_vpc.mlb_statsapi_vpc,
    aws_internet_gateway.igw
  ]
}


// ROUTE TABLE ASSOCIATIONS - PRIVATE
resource "aws_route_table_association" "rta_prv_a0"{
  subnet_id = aws_subnet.sn_prv_a0.id
  route_table_id = aws_route_table.rtb_prv_0.id
}
resource "aws_route_table_association" "rta_prv_b0"{
  subnet_id = aws_subnet.sn_prv_b0.id
  route_table_id = aws_route_table.rtb_prv_0.id
}

// ROUTE TABLE ASSOCIATIONS - PUBLIC
resource "aws_route_table_association" "rta_pub_a0"{
  subnet_id = aws_subnet.sn_pub_a0.id
  route_table_id = aws_route_table.rtb_pub_0.id
}
resource "aws_route_table_association" "rta_pub_b0"{
  subnet_id = aws_subnet.sn_pub_b0.id
  route_table_id = aws_route_table.rtb_pub_0.id
}


// IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id

  tags = {
    Name = "${local.vpc-name}-igw"
    Env = var.env_name
  }
}


//// NAT Gateway - PRIVATE
//resource "aws_nat_gateway" "nat_gw_prv_a0" {
//  allocation_id = aws_eip.nat_eip_prv_a0.id
//  subnet_id     = aws_subnet.sn_prv_a0.id
//
//  tags = {
//    Name = "${local.vpc-name}-nat-gw-prv-a0"
//    Env = var.env_name
//  }
//  # To ensure proper ordering, it is recommended to add an explicit dependency on the igw
//  depends_on = [aws_internet_gateway.igw]
//}

//resource "aws_nat_gateway" "nat_gw_prv_b0" {
//  allocation_id = aws_eip.nat_eip_prv_b0.id
//  subnet_id     = aws_subnet.sn_prv_b0.id
//
//  tags = {
//    Name = "${local.vpc-name}-nat-gw-prv-b0"
//    Env = var.env_name
//  }
//  depends_on = [aws_internet_gateway.igw]
//}


//// NAT Gateway - PUBLIC
//resource "aws_nat_gateway" "nat_gw_pub_a0" {
//  allocation_id = aws_eip.nat_eip_pub_a0.id
//  subnet_id     = aws_subnet.sn_pub_a0.id
//
//  tags = {
//    Name = "${local.vpc-name}-nat-gw-pub-a0"
//    Env = var.env_name
//  }
//  depends_on = [aws_internet_gateway.igw]
//}

//resource "aws_nat_gateway" "nat_gw_pub_b0" {
//  allocation_id = aws_eip.nat_eip_pub_b0.id
//  subnet_id     = aws_subnet.sn_pub_b0.id
//
//  tags = {
//    Name = "${local.vpc-name}-nat-gw-pub-b0"
//    Env = var.env_name
//  }
//  depends_on = [aws_internet_gateway.igw]
//}


// Endpoints
resource "aws_vpc_endpoint" "vpce_ecr_api_gw_ep" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.mlb_statsapi_sg.id]
  subnet_ids = [
    aws_subnet.sn_pub_a0.id,
    aws_subnet.sn_pub_b0.id
  ]
  private_dns_enabled = true
  tags = {
    Name = "${local.vpc-name}-vpce-ecr.api-gw-ep"
    Env = var.env_name
  }
}


////not sure if necessary - added while failing to run the ecs task
resource "aws_vpc_endpoint" "vpce_logs_gw_ep" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.logs"
  security_group_ids = [
    aws_security_group.mlb_statsapi_sg.id
  ]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.sn_pub_a0.id,
    aws_subnet.sn_pub_a0.id
  ]
  tags = {
    Name = "${local.vpc-name}-vpce-logs-gw-ep"
    Env = var.env_name
  }
}


resource "aws_vpc_endpoint" "vpce_s3_gw_ep" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::*",
                "arn:aws:s3:::*/*"
            ]
        }
    ]
}
POLICY
  tags = {
    Name = "${local.vpc-name}-vpce-s3-gw-ep"
    Env = var.env_name
  }
}


//resource "aws_vpc_endpoint" "vpce_sns_gw_ep" {
//  vpc_id = aws_vpc.mlb_statsapi_vpc.id
//  service_name = "com.amazonaws.${var.aws_region}.sns"
//  vpc_endpoint_type = "Interface"
//  security_group_ids = [aws_security_group.mlb_statsapi_sg.id]
//  subnet_ids = [
//    aws_subnet.sn_prv_a0.id,
//    aws_subnet.sn_prv_b0.id
//  ]
//  private_dns_enabled = true
//  tags = {
//    Name = "${local.vpc-name}-vpce-sns-gw-ep"
//    Env = var.env_name
//  }
//}


resource "aws_vpc_endpoint" "vpce_ecr_dkr_gw_ep" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.mlb_statsapi_sg.id]
  subnet_ids = [
    aws_subnet.sn_pub_a0.id,
    aws_subnet.sn_pub_b0.id
  ]
  private_dns_enabled = true

  depends_on = [
    aws_vpc.mlb_statsapi_vpc,
    aws_security_group.mlb_statsapi_sg,
    aws_subnet.sn_pub_a0,
    aws_subnet.sn_pub_b0
  ]
  tags = {
    Name = "${local.vpc-name}-vpce-ecr.dkr-gw-ep"
    Env = var.env_name
  }
}


//resource "aws_vpc_endpoint" "vpce_lambda_gw_ep" {
//  vpc_id = aws_vpc.mlb_statsapi_vpc.id
//  service_name = "com.amazonaws.${var.aws_region}.lambda-function-function"
//  vpc_endpoint_type = "Interface"
//
//  security_group_ids = [aws_security_group.mlb_statsapi_sg.id]
//  subnet_ids = [
//    aws_subnet.sn_prv_a0.id,
//    aws_subnet.sn_prv_b0.id
//  ]
//  private_dns_enabled = true
//  tags = {
//    Name = "${local.vpc-name}-vpce-lambda-function-function-gw-ep"
//    Env = var.env_name
//  }
//}



//resource "aws_vpc_endpoint" "vpce_states_gw_ep" {
//  vpc_id = aws_vpc.mlb_statsapi_vpc.id
//  service_name = "com.amazonaws.${var.aws_region}.states"
//  security_group_ids = [aws_security_group.mlb_statsapi_sg.id]
//  vpc_endpoint_type = "Interface"
//  private_dns_enabled = true
//  tags = {
//    Name = "${local.vpc-name}-vpce-states-gw-ep"
//    Env = var.env_name
//  }
//}


resource "aws_network_acl" "net_acl" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id
  subnet_ids = [
    aws_subnet.sn_prv_a0.id,
    aws_subnet.sn_prv_b0.id
  ]

  ingress {
    action = "allow"
    protocol = -1
    rule_no = 1
    from_port = 0
    to_port = 0
    cidr_block = aws_vpc.mlb_statsapi_vpc.cidr_block
  }

  egress {
    action = "allow"
    protocol = -1
    rule_no = 1
    from_port = 0
    to_port = 0
    cidr_block = aws_vpc.mlb_statsapi_vpc.cidr_block
  }
  tags = {
    Name = "${local.vpc-name}-net-acl"
    Env = var.env_name
  }
}

// Output - VPC Id
output "vpc_id" {
  value = aws_vpc.mlb_statsapi_vpc.id
}

// Output - Security Group Id
output "mlb_statsapi_sg-id" {
  value = aws_security_group.mlb_statsapi_sg.id
}

// Output - Private Subnet Ids
output "sn_prv_a0_id" {
  value = aws_subnet.sn_prv_a0.id
}
output "sn_prv_b0_id" {
  value = aws_subnet.sn_prv_b0.id
}

// Output - Public Subnet Is
output "sn_pub_a0_id" {
  value = aws_subnet.sn_pub_a0.id
}
output "sn_pub_b0_id" {
  value = aws_subnet.sn_pub_b0.id
}


// Output - aws_route_table and aws_route_table_association skipped

//// Output - Internet Gateway
//output "igw_id" {
//  value = aws_internet_gateway.igw.id
//}

//// Output - NAT EIP (Private)
//output "nat_eip_prv_a0_id" {
//  value = aws_eip.nat_eip_prv_a0.id
//}
//output "nat_eip_prv_b0_id" {
//  value = aws_eip.nat_eip_prv_b0.id
//}


//// Output - NAT EIP (Public)
//output "nat_eip_pub_a0_id" {
//  value = aws_eip.nat_eip_pub_a0.id
//}
//output "nat_eip_pub_b0_id" {
//  value = aws_eip.nat_eip_pub_b0.id
//}

//
//// Output - NAT Gateway (Private)
//output "nat_gw_prv_a0_id" {
//  value = aws_nat_gateway.nat_gw_prv_a0.id
//}
//output "nat_gw_prv_b0_id" {
//  value = aws_nat_gateway.nat_gw_prv_b0.id
//}

//// Output - NAT Gateway (Private)
//output "nat_gw_pub_a0_id" {
//  value = aws_nat_gateway.nat_gw_pub_a0.id
//}
//output "nat_gw_pub_b0_id" {
//  value = aws_nat_gateway.nat_gw_pub_b0.id
//}


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
