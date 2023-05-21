# configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Generate a secure key using a rsa algorithm
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# creating the keypair in aws
resource "aws_key_pair" "ec2_key" {
  key_name   = "my-ec2-keypair"                 
  public_key = tls_private_key.ec2_key.public_key_openssh 
}

# Save the .pem file locally for remote connection
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.ec2_key.key_name}.pem"
  content  = tls_private_key.ec2_key.private_key_pem
}

# create the security group to allow the ssh remote connection
# here the instance will be created in the default VPC
resource "aws_security_group" "ec2-security-group" {
  name        = "my-security-group"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create the ec2 instance
resource "aws_instance" "app_server" {
  ami           = "ami-0aedf6b1cb669b4c7"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2-security-group.id]

  tags = {
    Name = "my-ec2-instance"
    Env  = "dev"
  }
}

# print the ssh remote connection command
output "ssh_command" {
  value = "ssh -i my-ec2-keypair.pem centos@${aws_instance.app_server.public_ip}"
}