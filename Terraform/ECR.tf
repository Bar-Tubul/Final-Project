provider "aws" {
 
}

resource "aws_ecr_repository" "ecr_bop_repo" {
  name                 = "bop-ecr-repo"
  image_tag_mutability = "MUTABLE"  
  image_scanning_configuration {
    scan_on_push = true
  }
}
