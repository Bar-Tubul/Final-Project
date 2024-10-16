provider "aws" {
  
}
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.default.name
  multi_az             = true
  depends_on           = [aws_subnet.private_subnet] # Depends on created private subnets from the vpc.tf
  # snapshot_identifier  = "snapshot-id"
  tags = {
    Name = "BOP-statuspage"  # Tag to name the RDS instance
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "rds-private-subnet-group"  # The name of the subnet group
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "rds-private-subnet"  # Tag for the subnet group
  }
}
