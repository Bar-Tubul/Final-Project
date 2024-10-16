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
    subnet_ids = [
      aws_subnet.bop_private_subnet[0].id, 
      aws_subnet.bop_private_subnet[1].id  # Use only two AZs
    ]
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
        Action    = "sts:AssumeRole"
        Principal = {
          Service = [
            "eks.amazonaws.com",
            "ec2.amazonaws.com"  # Include EC2 service principal here
          ]
        }
        Effect    = "Allow"
        Sid       = ""
      },
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

# Node Group for Application (spans both AZs)
resource "aws_eks_node_group" "node_group_application" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "${var.node_group_name}-application"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    aws_subnet.bop_private_subnet[0].id, 
    aws_subnet.bop_private_subnet[1].id  # Nodes in both AZs
  ]

  scaling_config {
    desired_size = var.app_desired_capacity
    max_size     = var.app_max_size
    min_size     = var.app_min_size
  }

  depends_on = [aws_eks_cluster.my_cluster]

  # No additional parameters required for defaults
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

  # No additional parameters required for defaults
}





