resource "aws_db_subnet_group" "default" {
  name       = "rds-private-subnet-group"  # The name of the subnet group
  subnet_ids = aws_subnet.bop_private_subnet[*].id  # Reference to the private subnets

  tags = {
    Name = "rds-private-subnet"  # Tag for the subnet group
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20  # Increased storage size to 20 GB
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.default.name
  multi_az            = true
  depends_on          = [aws_db_subnet_group.default]  # Ensure this waits for the subnet group
  snapshot_identifier = "updated-bop-db"  # Ensure this matches an existing snapshot
  identifier          = "bop-statuspage"  # Set a specific identifier for the RDS instance

  tags = {
    Name = "BOP-statuspage"  # Tag to name the RDS instance
  }
}
