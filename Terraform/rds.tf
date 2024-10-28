# Create Security Group for RDS Instance
resource "aws_security_group" "bop_rds_sg" {
  name        = "bop-rds-sg"
  description = "Allow inbound PostgreSQL traffic on port 5432 for RDS instance"
  vpc_id      = aws_vpc.bop_vpc.id  # Reference the VPC where the RDS instance resides

  # Allow inbound traffic on PostgreSQL port 5432
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # Replace with specific IP ranges or security groups as needed for your application
    cidr_blocks = ["10.0.0.0/16"]  # Example VPC CIDR, tighten as needed
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bop-rds-sg"
  }
}

# Subnet Group for RDS Instance
resource "aws_db_subnet_group" "default" {
  name       = "bop-rds-private-subnet"  # The name of the subnet group
  subnet_ids = aws_subnet.bop_private_subnet[*].id  # Reference to the private subnets

  tags = {
    Name = "rds-private-subnet"
  }
}

# Create RDS Instance
resource "aws_db_instance" "default" {
  allocated_storage    = 20                    # Storage size in GB
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.default.name
  multi_az             = true
  vpc_security_group_ids = [aws_security_group.bop_rds_sg.id]  # Attach the security group
  snapshot_identifier  = "updated-bop-db"
  identifier           = "bop-statuspage"  # Set a specific identifier for the RDS instance

  tags = {
    Name = "BOP-statuspage"
  }

  depends_on = [aws_db_subnet_group.default]  # Ensure this waits for the subnet group
}
