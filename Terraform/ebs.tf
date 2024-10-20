provider "aws" {
  region = "us-east-1"  # Adjust to your preferred region
}

# Create an EBS volume for Redis
resource "aws_ebs_volume" "redis_ebs_volume" {
  availability_zone = "us-east-1a"  # Update to the availability zone of your EKS node group
  size              = 20            # Size in GB, adjust based on Redis requirements
  type              = "gp2"         # General Purpose SSD, can change to "io1" for more IOPS if needed
  tags = {
    Name = "redis-ebs-volume"
  }
}
