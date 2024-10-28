# Elasticache Redis Security Group
resource "aws_security_group" "bop_redis_sg" {
  vpc_id = aws_vpc.bop_vpc.id

  # Allow inbound traffic on Redis port 6379 from trusted sources only
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    # Allow traffic only from EKS Nodes security group
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
    Name = "bop-redis-sg"
  }
}

# Create ElastiCache Redis Subnet Group
resource "aws_elasticache_subnet_group" "bop_redis_subnet_group" {
  name       = "bop-redis-subnet-group"
  subnet_ids = [aws_subnet.bop_private_subnet[0].id, aws_subnet.bop_private_subnet[1].id]

  tags = {
    Name = "bop-redis-subnet-group"
  }
}

# Create ElastiCache Redis Replication Group
resource "aws_elasticache_replication_group" "bop_redis" {
  replication_group_id       = "bop-redis"
  description                = "Bop Redis"  

  engine                     = "redis"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 1
  automatic_failover_enabled = false

  security_group_ids         = [aws_security_group.bop_redis_sg.id]
  subnet_group_name          = aws_elasticache_subnet_group.bop_redis_subnet_group.name

  port                       = 6379;

  tags = {
    Name = "bop-redis"
  }
}
