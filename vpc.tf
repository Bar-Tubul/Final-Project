provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "BOP-VPC",
    Project = "TeamC"
  }
}

# create public subnets
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]

  availability_zone = lookup(var.subnet_az_map, var.public_subnet_cidrs[count.index])

  map_public_ip_on_launch = true

  tags = {
    Name = "BOP-public-subnet-${count.index + 1}"
    Project = "TeamC"
  }
}

# Create private subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]

  availability_zone = lookup(var.subnet_az_map, var.private_subnet_cidrs[count.index])

  tags = {
    Name = "BOP-private-subnet-${count.index + 1}"
    Project = "TeamC"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "BOP-internet-gateway"
    Project = "TeamC"
  }
}

# Create NAT Gateway
resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id  # NAT Gateway יהיה ברשת ציבורית הראשונה

  tags = {
    Name = "BOP-nat-gateway"
    Project = "TeamC"
  }
}

# Create route table for public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "BOP-public-route-table"
    Project = "TeamC"
  }
}

# associations public subnets to route table
resource "aws_route_table_association" "public_association" {
  count             = length(var.public_subnet_cidrs)
  subnet_id        = aws_subnet.public_subnet[count.index].id
  route_table_id   = aws_route_table.public_rt.id
}

# Create route table for private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id  # Routing outbound traffic through the NAT Gateway
  }

  tags = {
    Name = "BOP-private-route-table"
    Project = "TeamC"

  }
}

# associations private subnets to route table
resource "aws_route_table_association" "private_association" {
  count             = length(var.private_subnet_cidrs)
  subnet_id        = aws_subnet.private_subnet[count.index].id
  route_table_id   = aws_route_table.private_rt.id
}
