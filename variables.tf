# AWS Region
# Specifies the AWS region where all resources will be created.
variable "region" {
  description = "The AWS region to create resources in"
  default     = "us-east-1"
}

# VPC CIDR block
# Defines the CIDR block for the VPC, which acts as the private network range for all resources.
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Public Subnets CIDR blocks
# List of CIDR blocks for public subnets within the VPC. These subnets will have access to the internet.
variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

# Private Subnets CIDR blocks
# List of CIDR blocks for private subnets within the VPC. These subnets do not have direct access to the internet.
variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

# Availability Zones
# Defines the availability zones (AZs) for distributing resources, ensuring high availability. 
# Must match the region's AZs.
variable "availability_zones" {
  description = "The availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# RDS Username
# The master username for the RDS database instance.
# It's used to manage and access the database.
variable "db_username" {
  description = "The master username for the RDS instance"
  type        = string
  default     = "statuspage"
}

# RDS Password
# The master password for the RDS database instance.
# Used alongside the username for database authentication.
variable "db_password" {
  description = "The master password for the RDS instance"
  type        = string
  default     = "Passw0rd"
}

# EKS Cluster Name
# Specifies the name of the EKS cluster that will be created.
# This name will be used across resources related to the EKS cluster.
variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  default     = "bop-eks-cluster"
}

# Node Group Name
# Defines the base name for the EKS worker node groups.
# This name is used for the identification of node groups within the cluster.
variable "node_group_name" {
  description = "The name of the node group"
  default     = "bop-node-group"
}

# AZ1 Desired Capacity
# Specifies the desired number of worker nodes in the first availability zone (AZ1).
# Terraform will attempt to maintain this number of nodes.
variable "az1_desired_capacity" {
  description = "Desired number of nodes in AZ1"
  default     = 2
}

# AZ1 Maximum Size
# Specifies the maximum number of worker nodes that can be scaled in AZ1.
# Used for auto-scaling in case of demand spikes.
variable "az1_max_size" {
  description = "Maximum number of nodes in AZ1"
  default     = 2
}

# AZ1 Minimum Size
# Specifies the minimum number of worker nodes that should always be running in AZ1.
# Ensures that a baseline number of nodes is available at all times.
variable "az1_min_size" {
  description = "Minimum number of nodes in AZ1"
  default     = 1
}

# AZ2 Desired Capacity
# Specifies the desired number of worker nodes in the second availability zone (AZ2).
# Like AZ1, Terraform maintains this number of nodes in AZ2.
variable "az2_desired_capacity" {
  description = "Desired number of nodes in AZ2"
  default     = 1
}

# AZ2 Maximum Size
# Specifies the maximum number of worker nodes that can be scaled in AZ2.
# Limits the number of nodes for auto-scaling during high demand.
variable "az2_max_size" {
  description = "Maximum number of nodes in AZ2"
  default     = 1
}

# AZ2 Minimum Size
# Specifies the minimum number of worker nodes that should always be running in AZ2.
# Ensures basic availability of resources in AZ2.
variable "az2_min_size" {
  description = "Minimum number of nodes in AZ2"
  default     = 1
}

