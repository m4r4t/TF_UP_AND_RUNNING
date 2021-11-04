provider "aws" {
    region = "eu-west-1"
}

resource "aws_instance" "ec2_example_instance" {
  ami = "ami-08edbb0e85d6a0a07"
  instance_type = "t2.micro"
  security_groups = ["web_server_sg"]
  key_name = var.kp

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, world" > index.html
    nohup busybox httpd -f -p ${var.server_port}  &
    EOF

  tags = {
      Name = var.instance_name
  }
}


resource "aws_security_group" "web_server_sg" {
  name = "web_server_sg"

  ingress {
      from_port = var.server_port
      to_port = var.server_port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
