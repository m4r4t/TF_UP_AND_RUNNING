provider "aws" {
    region = "eu-west-1"
}

resource "aws_instance" "ec2_example_instance" {
  ami = "ami-08edbb0e85d6a0a07"
  instance_type = "t2.micro"

  tags = {
      Name = var.instance_name
  }
}

