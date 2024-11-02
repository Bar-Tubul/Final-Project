provider "aws" {
  region = "us-east-1"  # Change to your region
}

# Security Group for VPN
resource "aws_security_group" "vpn_sg" {
  vpc_id = "vpc-0aab7362a3bd6a284"  # Your VPC ID
  name   = "VPN-BOP-security-group"  # Name of the Security Group

  ingress {
    from_port   = 443      # HTTPS port
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS from anywhere
  }

  ingress {
    from_port   = 1194      # UDP port for OpenVPN
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow OpenVPN from anywhere
  }

  ingress {
    from_port   = 22        # SSH port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (not recommended for production)
  }

  ingress {
    from_port   = 943       # Port for OpenVPN web interface
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access to port 943 from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "TeamC"  # Adding tag to the Security Group
  }
}

# EC2 Instance with OpenVPN Access Server
resource "aws_instance" "vpn_instance" {
  ami           = "ami-06e5a963b2dadea6f"  # OpenVPN Access Server AMI
  instance_type = "t2.micro"
  subnet_id     = "subnet-0a3f9ed74ab378865"  # Your public subnet ID
  vpc_security_group_ids = [aws_security_group.vpn_sg.id]  # Attach the security group

  key_name      = "Bar-Peer-Or"  # Your key name

  tags = {
    Name    = "VPN-Instance"  # Adding a name tag to the EC2 instance
    Project = "TeamC"         # Adding the same tag to the EC2 instance
  }
}

output "vpn_instance_public_ip" {
  value = aws_instance.vpn_instance.public_ip
}
