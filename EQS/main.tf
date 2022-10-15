# Specific provider name according to the use case has to given!
provider "aws" {
  
  # Write the region name below in which your environment has to be deployed!
  region = "ap-south-1"

  # Assign the profile name here!
  profile = "eqs-test"
}

# Creating a New Key
resource "aws_key_pair" "Key-Pair" {

  # Name of the Key
  key_name   = "MyKeyFinal"

  # Adding the SSH authorized key !
  public_key = file("~/.ssh/authorized_keys")
  
 }

 # Creating a VPC!
resource "aws_vpc" "EQS" {
  
  # IP Range for the VPC
  cidr_block = "192.168.0.0/16"
  
  # Enabling automatic hostname assigning
  enable_dns_hostnames = true
  tags = {
    Name = "EQS"
  }
}

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

# Creating Public subnet!
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

# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_vpc.custom,
    aws_subnet.public_subnet1,
    aws_subnet.private_subnet1
  ]
  
  # VPC in which it has to be created!
  vpc_id = aws_vpc.EQS.id

  tags = {
    Name = "IG-Public-&-Private-VPC"
  }
}

# Creating an Route Table for the public subnet!
resource "aws_route_table" "Public-Subnet-RT" {
  depends_on = [
    aws_vpc.EQS,
    aws_internet_gateway.Internet_Gateway
  ]

   # VPC ID
  vpc_id = aws_vpc.EQS.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }

  tags = {
    Name = "Route Table for Internet Gateway"
  }
}


# Creating a resource for the Route Table Association!
resource "aws_route_table_association" "RT-IG-Association" {

  depends_on = [
    aws_vpc.EQS,
    aws_subnet.public_subnet1,
    aws_subnet.private_subnet1,
    aws_route_table.Public-Subnet-RT
  ]

# Public Subnet ID
  subnet_id      = aws_subnet.public_subnet1.id

#  Route Table ID
  route_table_id = aws_route_table.Public-Subnet-RT.id
}

