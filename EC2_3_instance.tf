# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
#creating the ec2 instance
resource "aws_instance" "app_server" {
  count         = 3 
  ami           = "ami-06a0cd9728546d178"
  instance_type = "t2.micro"

  tags = {
    Name ="my-instance-${count.index + 1}"
    Environment  = "dev"
    
  }
}

  

