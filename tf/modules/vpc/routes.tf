resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id

  tags = {
    Name = "${local.vpc-name}-igw"
    Env = var.env_name
  }
}

/*
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id

//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = aws_nat_gateway.nat_gw_private_a0.id
//  }

  tags = {
    Name = "${var.env_name}-rt-private-0"
  }
}
*/


resource "aws_route_table" "public" {
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


// ROUTE TABLE ASSOCIATIONS
/*
resource "aws_route_table_association" "rta_private_a0"{
  count = local.count
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
*/
resource "aws_route_table_association" "public"{
  count = local.count
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

/*
resource "aws_network_acl" "net_acl" {
  vpc_id = aws_vpc.mlb_statsapi_vpc.id
  subnet_ids = aws_subnet.private[*].id

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
*/
