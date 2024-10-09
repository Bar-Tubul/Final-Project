provider "aws" {
  region = var.region
}

# יצירת VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "BOP-VPC"
  }
}

# יצירת רשתות ציבוריות
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "my-public-subnet-${count.index + 1}"
  }
}

# יצירת רשתות פרטיות
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "my-private-subnet-${count.index + 1}"
  }
}

# יצירת Gateway ציבורי
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-internet-gateway"
  }
}

# יצירת NAT Gateway
resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id  # NAT Gateway יהיה ברשת ציבורית הראשונה

  tags = {
    Name = "my-nat-gateway"
  }
}

# יצירת טבלה ניהולית ציבורית
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "my-public-route-table"
  }
}

# חיבור טבלה ניהולית לרשתות הציבוריות
resource "aws_route_table_association" "public_association" {
  count             = length(var.public_subnet_cidrs)
  subnet_id        = aws_subnet.public_subnet[count.index].id
  route_table_id   = aws_route_table.public_rt.id
}

# יצירת טבלה ניהולית פרטית
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id  # ניתוב לתעבורה החוצה דרך ה-NAT Gateway
  }

  tags = {
    Name = "my-private-route-table"
  }
}

# חיבור טבלה ניהולית לרשתות הפרטיות
resource "aws_route_table_association" "private_association" {
  count             = length(var.private_subnet_cidrs)
  subnet_id        = aws_subnet.private_subnet[count.index].id
  route_table_id   = aws_route_table.private_rt.id
}
