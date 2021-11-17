provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "test" {
  enable_dns_support   = true
  enable_dns_hostnames = true

  cidr_block = "10.7.0.0/16"
  tags = {
    "Name" = "Test vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.test.id
  cidr_block              = "10.7.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Public subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = "10.7.100.0/24"
  availability_zone = "eu-west-1b"
  tags = {
    "Name" = "Private subnet"
  }
}


resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test.id
}

resource "aws_eip" "nat" {


}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.test.main_route_table_id
  tags = {
    "Name" = "Dafault(main)"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.test.id

  tags = {
    "Name" = "Private"
  }
}

resource "aws_route" "public_internet_gw" {
  route_table_id         = aws_default_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.test_igw.id
}

resource "aws_route" "priv_internet_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.natgw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_default_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "web_server_sg" {
  vpc_id = aws_vpc.test.id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "web_server_sg"
  }
}

resource "aws_security_group" "priv_sg" {
  vpc_id = aws_vpc.test.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.7.1.0/24"]
  }

  ingress {
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["10.7.1.0/24"]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    "Name" = "Private SG"
  }
}

resource "aws_instance" "ec2-public-access" {
  ami                    = "ami-08edbb0e85d6a0a07"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  key_name               = var.kp

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, world" > index.html
    nohup busybox httpd -f -p ${var.server_port}  &
    EOF

  tags = {
    Name = var.instance_name
  }
}

resource "aws_instance" "ec2-private-access" {
  ami                    = "ami-08edbb0e85d6a0a07"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.priv_sg.id]
  key_name               = var.kp

  tags = {
    "Name" = "Private EC2"
  }
}


