# AWS Provider Configuration
provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "bop_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "bop-vpc"
  }
}

# Create Public Subnets
resource "aws_subnet" "bop_public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.bop_vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "bop-public-subnet-${count.index + 1}"
  }
}

# Create Private Subnets
resource "aws_subnet" "bop_private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.bop_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "bop-private-subnet-${count.index + 1}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "bop_igw" {
  vpc_id = aws_vpc.bop_vpc.id

  tags = {
    Name = "bop-internet-gateway"
  }
}

# Create NAT Gateway and Elastic IP
resource "aws_eip" "bop_nat_eip" {}

resource "aws_nat_gateway" "bop_nat" {
  allocation_id = aws_eip.bop_nat_eip.id
  subnet_id     = aws_subnet.bop_public_subnet[0].id

  tags = {
    Name = "bop-nat-gateway"
  }
}

# Create Public Route Table
resource "aws_route_table" "bop_public_rt" {
  vpc_id = aws_vpc.bop_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bop_igw.id
  }

  tags = {
    Name = "bop-public-route-table"
  }
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "bop_public_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.bop_public_subnet[count.index].id
  route_table_id = aws_route_table.bop_public_rt.id
}

# Create Private Route Table
resource "aws_route_table" "bop_private_rt" {
  vpc_id = aws_vpc.bop_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.bop_nat.id
  }

  tags = {
    Name = "bop-private-route-table"
  }
}

# Associate Private Route Table with Private Subnets
resource "aws_route_table_association" "bop_private_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.bop_private_subnet[count.index].id
  route_table_id = aws_route_table.bop_private_rt.id
}

# Create Security Group for Status Page Application
resource "aws_security_group" "bop_statuspage_sg" {
  vpc_id = aws_vpc.bop_vpc.id

  # Allow HTTP access on port 80 from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS access on port 443 from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow access for Redis on port 6379 (only from the web application security group)
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [aws_security_group.bop_statuspage_sg.id]
  }

  # Allow access for RDS on port 5432 (only from the web application security group)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.bop_statuspage_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bop-statuspage-sg"
  }
}
