provider "aws" {
  region = "us-west-2"  # Replace with your preferred AWS region
}

resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = "vpc-xxxxxxxx"  # Replace with your VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8001  # Allow port 8001 for specific application
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an ALB
resource "aws_lb" "example" {
  name               = "example-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-xxxxxxxx", "subnet-xxxxxxxx"]  # Replace with your subnet IDs

  enable_deletion_protection = false
}

# Create Target Group for EKS pods/services (still using 'ip')
resource "aws_lb_target_group" "eks_tg" {
  name        = "eks-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "vpc-xxxxxxxx"  # Replace with your VPC ID

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Listener for ALB
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_tg.arn
  }
}

# Attach EKS Pods/Services to the Target Group (using pod IPs or service IPs)
resource "aws_lb_target_group_attachment" "eks_jenkins_attachment" {
  target_group_arn = aws_lb_target_group.eks_tg.arn
  target_id        = "JENKINS_POD_IP"  # Replace with Jenkins pod IP or service IP
  port             = 8080  # Jenkins usually runs on 8080
}

resource "aws_lb_target_group_attachment" "eks_grafana_attachment" {
  target_group_arn = aws_lb_target_group.eks_tg.arn
  target_id        = "GRAFANA_POD_IP"  # Replace with Grafana pod IP or service IP
  port             = 3000  # Grafana typically runs on 3000
}

resource "aws_lb_target_group_attachment" "eks_prometheus_attachment" {
  target_group_arn = aws_lb_target_group.eks_tg.arn
  target_id        = "PROMETHEUS_POD_IP"  # Replace with Prometheus pod IP or service IP
  port             = 9090  # Prometheus default port
}

resource "aws_lb_target_group_attachment" "eks_nginx_attachment" {
  target_group_arn = aws_lb_target_group.eks_tg.arn
  target_id        = "NGINX_POD_IP"  # Replace with NGINX pod IP or service IP
  port             = 80  # NGINX typically runs on port 80
}

resource "aws_lb_target_group_attachment" "eks_postgresql_attachment" {
  target_group_arn = aws_lb_target_group.eks_tg.arn
  target_id        = "POSTGRES_POD_IP"  # Replace with PostgreSQL pod IP or service IP
  port             = 5432  # PostgreSQL default port
}

resource "aws_lb_target_group_attachment" "eks_app8001_attachment" {
  target_group_arn = aws_lb_target_group.eks_tg.arn
  target_id        = "APP_POD_IP"  # Replace with application pod IP or service IP
  port             = 8001  # Custom application running on port 8001
}
