# Creating Public subnet!
resource "aws_subnet" "public_subnet1" {
  depends_on = [
    aws_vpc.EQS
  ]
  
  # VPC in which subnet has to be created!
  vpc_id = aws_vpc.EQS.id
  
  # IP Range of this subnet
  cidr_block = "192.168.0.0/24"
  
  # Data Center of this subnet.
  availability_zone = "ap-south-1a"
  
  # Enabling automatic public IP assignment on instance launch!
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

# Creating Private subnet!
resource "aws_subnet" "private_subnet1" {
  depends_on = [
    aws_vpc.EQS,
    aws_subnet.public_subnet1
  ]
  
  # VPC in which subnet has to be created!
  vpc_id = aws_vpc.EQS.id
  
  # IP Range of this subnet
  cidr_block = "192.168.1.0/24"
  
  # Data Center of this subnet.
  availability_zone = "ap-south-1b"
  
  tags = {
    Name = "Private Subnet"
  }
}