provider "aws" {
  region = var.region
}

# יצירת VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "my-vpc"
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
  subnet_id     = aws_subnet.public_subnet[0].id

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
    nat_gateway_id = aws_nat_gateway.nat.id
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

# יצירת Security Group
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-web-sg"
  }
}

############################################

# יצירת קלאסטר EKS
resource "aws_eks_cluster" "my_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.private_subnet[*].id
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

# יצירת IAM Role לקלאסטר EKS
resource "aws_iam_role" "eks_role" {
  name = "${var.eks_cluster_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# חיבור מדיניות IAM לקלאסטר EKS
resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# יצירת Node Group עבור איזור 1
resource "aws_eks_node_group" "node_group_1" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "${var.node_group_name}-az1"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.private_subnet[0].id]
  desired_size    = var.az1_desired_capacity
  max_size        = var.az1_max_size
  min_size        = var.az1_min_size

  depends_on = [aws_eks_cluster.my_cluster]
}

# יצירת Node Group עבור איזור 2
resource "aws_eks_node_group" "node_group_2" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "${var.node_group_name}-az2"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.private_subnet[1].id]
  desired_size    = var.az2_desired_capacity
  max_size        = var.az2_max_size
  min_size        = var.az2_min_size

  depends_on = [aws_eks_cluster.my_cluster]
}

# יצירת IAM Role לנודים
resource "aws_iam_role" "eks_node_role" {
  name = "${var.node_group_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# חיבור מדיניות IAM לנודים
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
