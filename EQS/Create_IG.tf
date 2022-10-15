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