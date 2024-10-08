# AWS Region
variable "region" {
  description = "The AWS region to create resources in"
  default     = "us-east-1"
}

# VPC CIDR block
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Public Subnets CIDR blocks
variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

# Private Subnets CIDR blocks
variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

# Availability Zones
variable "availability_zones" {
  description = "The availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# RDS Username
variable "db_username" {
  description = "The master username for the RDS instance"
  type        = string
  default     = "statuspage"
}

# RDS Password
variable "db_password" {
  description = "The master password for the RDS instance"
  type        = string
  default     = "Passw0rd"
}


