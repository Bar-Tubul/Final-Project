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
  default     = "P@ssw0rd"
}

# EKS Cluster Name
variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  default     = "bop-eks-cluster"
}

# Node Group Name
variable "node_group_name" {
  description = "The name of the node group"
  default     = "bop-node-group"
}

# Application Node Group Capacity
variable "app_desired_capacity" {
  description = "Desired number of nodes for the application node group"
  type        = number
  default     = 1
}

variable "app_max_size" {
  description = "Maximum number of nodes for the application node group"
  type        = number
  default     = 3
}

variable "app_min_size" {
  description = "Minimum number of nodes for the application node group"
  type        = number
  default     = 1
}

# Monitoring Node Group Capacity
variable "monitoring_desired_capacity" {
  description = "Desired number of nodes for the monitoring node group"
  type        = number
  default     = 1
}

variable "monitoring_max_size" {
  description = "Maximum number of nodes for the monitoring node group"
  type        = number
  default     = 1
}

variable "monitoring_min_size" {
  description = "Minimum number of nodes for the monitoring node group"
  type        = number
  default     = 1
}
