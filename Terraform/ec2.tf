# EC2 instance 
resource "aws_instance" "bop_statuspage_ec2" {
  ami                    = "ami-xxxxxxxxxxxxxxx"  #  custom AMI ID
  instance_type          = "t2.medium"             
  subnet_id              = aws_subnet.bop_private_subnet[0].id
  vpc_security_group_ids = [aws_security_group.bop_statuspage_ec2.id]
  
  # Configure tags for identification
  tags = {
    Name = "bop-statuspage-ec2"
  }

  
  depends_on = [aws_vpc.bop_vpc]
}
Test2
Test5
gfgfg