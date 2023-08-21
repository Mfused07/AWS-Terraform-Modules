
# Define the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name   = "${var.client_name}-vpc"
    Client = "${var.client_name}"
    env    = "${var.environment}"
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "${var.client_name}-${var.public_subnet_names[count.index]}"
  }

}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.client_name}-${var.private_subnet_names[count.index]}"
  }
}

# Create services subnet
resource "aws_subnet" "services_subnet" {
  count = length(var.services_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.services_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.client_name}-${var.services_subnet_names[count.index]}"
  }
}

# Create a public route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.client_name}-public-rt"
  }
}

# Create private route table with private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.client_name}-private-rt"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_names)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_names)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
# Associate private subnets with the private route table
resource "aws_route_table_association" "services_subnet_association" {
  count          = length(var.services_subnet_names)
  subnet_id      = aws_subnet.services_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# Create an Internet Gateway for Public Subnets
resource "aws_internet_gateway" "client_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name   = "${var.client_name}-igw"
    Client = "${var.client_name}"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name   = "${var.client_name}-nat-eip"
    Client = var.client_name
  }
}

# Create an Internet Gateway for Services and Private Subnets
resource "aws_nat_gateway" "nat_gateway" {
  # count       = length(var.private_subnet_names)
  subnet_id     = aws_subnet.private_subnet[0].id # Use any private subnet ID here
  allocation_id = aws_eip.nat_eip.id

  tags = {
    Name   = "${var.client_name}-nat-gateway"
    Client = var.client_name
  }
}

# Create a private route in the private route table to point to the NAT Gateway
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Create a public route in the public route table to point to the Internet Gateway
resource "aws_route" "public_igw_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.client_igw.id
}

# Create a Network Gateway (Virtual Private Gateway)
resource "aws_vpn_gateway" "client_ngw" {
  tags = {
    Name   = "${var.client_name}-ngw"
    Client = "${var.client_name}"

  }
}

# Create Network ACL for db-subnests
resource "aws_network_acl" "vpc_acl" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.client_name}-db-subnet-acl"
  }
}

# Inbound Rules
resource "aws_network_acl_rule" "inbound_rule_1" {
  network_acl_id = aws_network_acl.vpc_acl.id
  rule_number    = 100
  protocol       = "6"    # TCP
  rule_action    = "allow"
  egress         = false  # Inbound
  cidr_block     = "10.47.0.0/24"
  from_port      = 5432
  to_port        = 5432
}

resource "aws_network_acl_rule" "inbound_rule_2" {
  network_acl_id = aws_network_acl.vpc_acl.id
  rule_number    = 101
  protocol       = "6"    # TCP
  rule_action    = "allow"
  egress         = false  # Inbound
  cidr_block     = "172.29.2.0/24"
  from_port      = 5432
  to_port        = 5432
}

# Outbound Rules
resource "aws_network_acl_rule" "outbound_rule_1" {
  network_acl_id = aws_network_acl.vpc_acl.id
  rule_number    = 100
  protocol       = "-1"   # All
  rule_action    = "allow"
  egress         = true   # Outbound
  cidr_block     = "0.0.0.0/0"
}

# Create security group
resource "aws_security_group" "main" {
  name        = "${var.client_name}-security-group"
  description = "Main security group for the VPC"
  vpc_id      = aws_vpc.main.id
  tags = {
    Client = "${var.client_name}"
  }

}


