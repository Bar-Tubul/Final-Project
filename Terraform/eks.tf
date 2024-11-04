# Create Security Group for EKS Cluster
resource "aws_security_group" "eks_sg" {
  name   = "${var.eks_cluster_name}-sg"
  vpc_id = aws_vpc.bop_vpc.id  

  # Allow inbound HTTPS from the EKS Node Group security group
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  # Allow HTTPS traffic from Jenkins
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  # Allow self-referencing traffic (all)
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.eks_cluster_name}-sg"
  }
}

# Create Security Group for EKS Nodes
resource "aws_security_group" "eks_nodes" {
  vpc_id = aws_vpc.bop_vpc.id

  # Allow HTTPS traffic from Jenkins security group
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  # Allow all traffic from EKS Cluster security group
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_sg.id]
  }

  # Allow all traffic from Node Group self-reference
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.eks_cluster_name}-nodes-sg"
  }
}

# Create IAM Role for EKS Cluster
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

# Attach IAM Policy to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create EKS Cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids             = aws_subnet.bop_private_subnet[*].id
    security_group_ids     = [aws_security_group.eks_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

# Create IAM Role for Node Groups
resource "aws_iam_role" "eks_node_role" {
  name = "${var.node_group_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "eks.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach IAM Policies to Node Groups
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Node Group for Application (spans both AZs)
resource "aws_eks_node_group" "node_group_application" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "${var.node_group_name}-application"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.bop_private_subnet[*].id  # Nodes in both AZs

  scaling_config {
    desired_size = var.app_desired_capacity
    max_size     = var.app_max_size
    min_size     = var.app_min_size
  }

  depends_on = [aws_eks_cluster.my_cluster]
}

# Node Group for Monitoring (only in one AZ)
resource "aws_eks_node_group" "node_group_monitoring" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "${var.node_group_name}-monitoring"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.bop_private_subnet[0].id]  # Nodes only in the first AZ

  scaling_config {
    desired_size = var.monitoring_desired_capacity
    max_size     = var.monitoring_max_size
    min_size     = var.monitoring_min_size
  }

  depends_on = [aws_eks_cluster.my_cluster]
}
