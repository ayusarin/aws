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