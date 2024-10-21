# Node Group for Application (spans both AZs)
resource "aws_eks_node_group" "node_group_application" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "${var.node_group_name}-application"  # Original name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    aws_subnet.bop_private_subnet[0].id, 
    aws_subnet.bop_private_subnet[1].id  # Nodes in both AZs
  ]
  
  # Specify instance type
  instance_type   = "t2.medium"

  scaling_config {
    desired_size = var.app_desired_capacity
    max_size     = var.app_max_size
    min_size     = var.app_min_size
  }

  depends_on = [aws_eks_cluster.my_cluster]
}

# Node Group for Application (another instance with a different name)
resource "aws_eks_node_group" "node_group_application_1" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "${var.node_group_name}-application-1"  # New name for differentiation
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    aws_subnet.bop_private_subnet[0].id, 
    aws_subnet.bop_private_subnet[1].id  # Nodes in both AZs
  ]

  # Specify instance type
  instance_type   = "t2.medium"

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

  # Specify instance type
  instance_type   = "t2.medium"

  scaling_config {
    desired_size = var.monitoring_desired_capacity
    max_size     = var.monitoring_max_size
    min_size     = var.monitoring_min_size
  }

  depends_on = [aws_eks_cluster.my_cluster]
}
