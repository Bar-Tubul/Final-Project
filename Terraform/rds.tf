# Create Security Group for RDS Instance
resource "aws_security_group" "bop_rds_sg" {
  name        = "bop-rds-sg"
  description = "Allow access to RDS instance"

  vpc_id = aws_vpc.bop_vpc.id

  # Allow inbound traffic on PostgreSQL port 5432 from EKS Nodes
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
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

# Create RDS Instance
resource "aws_db_instance" "bop_rds" {
  identifier        = "bop-rds"
  instance_class    = "db.t3.micro"
  engine            = "postgres"
  allocated_storage  = 20
  username          = var.db_username
  password          = var.db_password
  db_name           = var.db_name
  skip_final_snapshot = true

  # Using the security group we created for RDS
  vpc_security_group_ids = [aws_security_group.bop_rds_sg.id]

  # Specify the DB subnet group if required
  db_subnet_group_name = aws_db_subnet_group.bop_rds_subnet_group.name

  tags = {
    Name = "bop-rds"
  }
}
