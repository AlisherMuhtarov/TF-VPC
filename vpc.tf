resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public_subnets" {
  count = 4
  vpc_id = aws_vpc.main.id
  cidr_block = local.public_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

}

resource "aws_subnet" "private_subnets" {
  count = 4
  vpc_id = aws_vpc.main.id
  cidr_block = local.private_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "homework"
  }
}

resource "aws_internet_gateway_attachment" "app" {
  internet_gateway_id = aws_internet_gateway.gw.id
  vpc_id              = aws_vpc.main.id
}

resource "aws_route_table" "pub_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.route_pub
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "app-public-rt1"
  }
}

resource "aws_route_table" "priv_route" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "app-private-rt1"
  }
}

resource "aws_route_table_association" "public" {
  count = 4
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.pub_route.id
}

resource "aws_route_table_association" "private" {
  count = 4
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.priv_route.id
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  # Inbound Rules
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 22
    to_port    = 22
  }

  # Outbound Rules
  egress {
    rule_no    = 200
    action     = "allow"
    protocol   = "-1"
    cidr_block = var.route_pub
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 210
    action     = "allow"
    protocol   = "tcp"
    cidr_block = var.route_pub
    from_port  = 80
    to_port    = 443
  }

  tags = {
    Name = "main"
  }
}

# Associate NACL with Public Subnets
resource "aws_network_acl_association" "public_nacl_association" {
  count = 4
  subnet_id       = aws_subnet.public_subnets[count.index].id
  network_acl_id  = aws_network_acl.main.id
}
