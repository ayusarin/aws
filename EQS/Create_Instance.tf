# Creating an AWS instance for the Webserver!
resource "aws_instance" "node" {

  depends_on = [
    aws_vpc.EQS,
    aws_subnet.public_subnet1,
    aws_subnet.private_subnet1,
    aws_security_group.NODE-SG,
  ]
  
  # AMI ID [I have used my custom AMI which has some softwares pre installed]
  ami = "ami-024c319d5d14b463e"
  instance_type = "t2.medium"
  subnet_id = aws_subnet.public_subnet1.id

  # Keyname and security group are obtained from the reference of their instances created above!
  # Here I am providing the name of the key which is already uploaded on the AWS console.
  key_name = "MyKeyFinal"
  
  # Security groups to use!
  vpc_security_group_ids = [aws_security_group.NODE-SG.id]

  tags = {
   Name = "Node_From_Terraform"
  }

  # Installing required softwares into the system!
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("/Users/harshitdawar/Github/AWS-CLI/MyKeyFinal.pem")
    host = aws_instance.webserver.public_ip
  }

  # Code for installing the softwares!
  provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
        "sudo yum install php php-mysqlnd httpd -y",
        "wget https://wordpress.org/wordpress-4.8.14.tar.gz",
        "tar -xzf wordpress-4.8.14.tar.gz",
        "sudo cp -r wordpress /var/www/html/",
        "sudo chown -R apache.apache /var/www/html/",
        "sudo systemctl start httpd",
        "sudo systemctl enable httpd",
        "sudo systemctl restart httpd"
    ]
  }
}