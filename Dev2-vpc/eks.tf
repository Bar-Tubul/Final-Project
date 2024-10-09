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

  scaling_config {
    desired_size = var.az1_desired_capacity
    max_size     = var.az1_max_size
    min_size     = var.az1_min_size
  }

  depends_on = [aws_eks_cluster.my_cluster]
}

# יצירת Node Group עבור איזור 2
resource "aws_eks_node_group" "node_group_2" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "${var.node_group_name}-az2"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.private_subnet[1].id]

  scaling_config {
    desired_size = var.az2_desired_capacity
    max_size     = var.az2_max_size
    min_size     = var.az2_min_size
  }

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
