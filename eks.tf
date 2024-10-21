# Create IAM Role for EKS Cluster
resource "aws_iam_role" "eks_role" {
  name = "bop-eks-cluster-role"

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
resource "aws_eks_cluster" "bop_eks_cluster" {  # Updated cluster name reference
  name     = "bop-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids              = [
      aws_subnet.bop_private_subnet[0].id, 
      aws_subnet.bop_private_subnet[1].id  # Use only two AZs
    ]
    endpoint_private_access = true  # Enable private access
    endpoint_public_access  = false  # Disable public access for security
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

# Create IAM Role for Node Groups
resource "aws_iam_role" "eks_node_role" {
  name = "${var.node_group_name}-role"

  # Add both EKS and EC2 to the trust relationship
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "eks.amazonaws.com",  # EKS service principal
            "ec2.amazonaws.com"   # EC2 service principal
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

# Attach EC2 Container Registry read-only policy
resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create Custom ECR Policy
resource "aws_iam_policy" "ecr_custom_policy" {
  name        = "${var.node_group_name}-ECR-Access"
  description = "Custom policy to allow access to ECR for pulling images"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach Custom ECR Policy to Node Groups
resource "aws_iam_role_policy_attachment" "ecr_custom_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.ecr_custom_policy.arn
}

# Node Group for Application 1 (spans both AZs)
resource "aws_eks_node_group" "application_node_group" {
  cluster_name    = aws_eks_cluster.bop_eks_cluster.name  # Updated reference
  node_group_name = "${var.node_group_name}-application-1"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    aws_subnet.bop_private_subnet[0].id, 
    aws_subnet.bop_private_subnet[1].id  # Nodes in both AZs
  ]
  
  # Set the instance type to t2.medium
  instance_type   = "t2.medium"

  scaling_config {
    desired_size = var.app_desired_capacity
    max_size     = var.app_max_size
    min_size     = var.app_min_size
  }

  depends_on = [aws_eks_cluster.bop_eks_cluster]  # Updated reference
}

# Node Group for Application 2 (spans both AZs)
resource "aws_eks_node_group" "application_node_group_1" {
  cluster_name    = aws_eks_cluster.bop_eks_cluster.name  # Updated reference
  node_group_name = "${var.node_group_name}-application-2"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    aws_subnet.bop_private_subnet[0].id, 
    aws_subnet.bop_private_subnet[1].id  # Nodes in both AZs
  ]

  # Set the instance type to t2.medium
  instance_type   = "t2.medium"

  scaling_config {
    desired_size = var.app_desired_capacity
    max_size     = var.app_max_size
    min_size     = var.app_min_size
  }

  depends_on = [aws_eks_cluster.bop_eks_cluster]  # Updated reference
}

# Node Group for Monitoring (only in one AZ)
resource "aws_eks_node_group" "node_group_monitoring" {
  cluster_name    = aws_eks_cluster.bop_eks_cluster.name  # Updated reference
  node_group_name = "${var.node_group_name}-monitoring"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.bop_private_subnet[0].id]  # Nodes only in the first AZ

  scaling_config {
    desired_size = var.monitoring_desired_capacity
    max_size     = var.monitoring_max_size
    min_size     = var.monitoring_min_size
  }

  depends_on = [aws_eks_cluster.bop_eks_cluster]  # Updated reference
}
