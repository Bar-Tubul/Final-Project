provider "aws" {
 
}

resource "aws_ecr_repository" "my_ecr_repo" {
  name                 = "bop-ecr-repo"
  image_tag_mutability = "MUTABLE"  
  image_scanning_configuration {
    scan_on_push = true
  }
}