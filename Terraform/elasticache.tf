# Elasticache Redis Security Group
resource "aws_security_group" "bop_redis_sg" {
  vpc_id = aws_vpc.bop_vpc.id

  # Allow all inbound traffic (for testing purposes) - Consider tightening for production use
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
  replication_group_id = "bop-redis"
  description          = "Bop Redis replication group"  # Changed from replication_group_description to description

  engine               = "redis"
  node_type            = "cache.t3.micro"               # Small instance for testing
  num_cache_clusters   = 1                              # Corrected: Only 1 node, no replicas
  automatic_failover_enabled = false                    # No failover with a single node

  security_group_ids   = [aws_security_group.bop_redis_sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.bop_redis_subnet_group.name

  port                 = 6379

  tags = {
    Name = "bop-redis"
  }
}
