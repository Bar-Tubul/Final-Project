variable "region" {
  description = "The AWS region to create resources in"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "The availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  default     = "my-eks-cluster"
}

variable "node_group_name" {
  description = "The name of the node group"
  default     = "my-node-group"
}

variable "az1_desired_capacity" {
  description = "Desired number of nodes in AZ1"
  default     = 2
}

variable "az1_max_size" {
  description = "Maximum number of nodes in AZ1"
  default     = 2
}

variable "az1_min_size" {
  description = "Minimum number of nodes in AZ1"
  default     = 1
}

variable "az2_desired_capacity" {
  description = "Desired number of nodes in AZ2"
  default     = 1
}

variable "az2_max_size" {
  description = "Maximum number of nodes in AZ2"
  default     = 1
}

variable "az2_min_size" {
  description = "Minimum number of nodes in AZ2"
  default     = 1
}
