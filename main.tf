provider "aws" {
    region = "eu-west-1"
}

resource "aws_vpc" "test_vpc" {


    enable_dns_support   = true
    enable_dns_hostnames = true

    cidr_block = "10.7.0.0/16"
    tags =  {
        "Name" = "test_vpc"
    }
}

resource "aws_subnet" "test_subnet" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "10.7.1.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "test_subnet"
  }
}

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id
}

resource "aws_default_route_table" "public" {
    default_route_table_id = aws_vpc.test_vpc.main_route_table_id
  
}

resource "aws_route" "public_internet_gw" {
  route_table_id = aws_default_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.test_igw.id
  }

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.test_subnet.id
  route_table_id = aws_default_route_table.public.id
}

resource "aws_security_group" "web_server_sg" {
  
  vpc_id = aws_vpc.test_vpc.id

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

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "name" = "web_server_sg"
  }
}

resource "aws_instance" "ec2_example_instance" {
  ami = "ami-08edbb0e85d6a0a07"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.test_subnet.id
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
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



