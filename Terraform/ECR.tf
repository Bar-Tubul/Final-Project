terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Adjust the version as needed
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"  # Adjust to your desired AWS region
}

resource "aws_ecr_repository" "statuspage_bop" {
  name                 = "statuspage-bop"
  image_tag_mutability = "MUTABLE"

  tags = {
    Project = "TeamC"
  }
}

resource "aws_ecr_repository" "nginx_bop" {
  name                 = "nginx-bop"
  image_tag_mutability = "MUTABLE"

  tags = {
    Project = "TeamC"
  }
}
