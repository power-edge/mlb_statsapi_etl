locals {
  name = var.env_name
  availability_zones-available_names = data.aws_availability_zones.available.names
  count = length(local.availability_zones-available_names)
}

data "aws_availability_zones" "available" {}

// VPC
resource "aws_vpc" "mlb_statsapi_vpc" {
  cidr_block = "10.${var.cidr_b}.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = local.vpc-name
  }

  depends_on = [data.aws_availability_zones.available]
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


/*
resource "aws_subnet" "private" {
  count = local.count
  availability_zone       = local.availability_zones-available_names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.mlb_statsapi_vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.mlb_statsapi_vpc.id
  tags = {
    Name = "mlb-statsapi-etl-private-node-${data.aws_availability_zones.available.names[count.index]}"
    Env = var.env_name
  }

  depends_on = [data.aws_availability_zones.available]
}
*/

resource "aws_subnet" "public" {
  count = local.count
  availability_zone       = local.availability_zones-available_names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.mlb_statsapi_vpc.cidr_block, 8, sum([local.count, count.index]))
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.mlb_statsapi_vpc.id
  tags = {
    Name = "mlb-statsapi-etl-public-node-${data.aws_availability_zones.available.names[count.index]}"
    Env = var.env_name
  }
}

