terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "vpc_terraform" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name      = "VPC TERRAFORM"
    Owner     = "Douglas"
    CreatedAt = "2023-02-23"
  }

}

#Creat subnet
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.vpc_terraform.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zones[0] # Variable declared in variables.tfvars 

  tags = {
    Name = "Subnet1"
    Type = "Public"
  }
}

#Creat subnet 2
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.vpc_terraform.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zones[1] # Variable declared in variables.tfvars 

  tags = {
    Name = "Subnet2"
    Type = "Public"
  }
}

# Configuring internet gateway
resource "aws_internet_gateway" "vpc_terraform" {
  vpc_id = aws_vpc.vpc_terraform.id

  tags = {
    Name      = "GW VPC SUBNET1 TERRAFORM"
    Owner     = "Douglas"
    CreatedAt = "2023-02-23"
  }
}

# Configuring route table

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc_terraform.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_terraform.id
  }

  #route {
  #  ipv6_cidr_block        = "::/0"
  #  egress_only_gateway_id = aws_egress_only_internet_gateway.vpc_terraform.id
  #}

  tags = {
    Name = "Public"
  }
}

# Configuring route table association

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt1.id
}

# Configuring security group
resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "Webserver network traffic"
  vpc_id      = aws_vpc.vpc_terraform.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.workstation_ip]
    # ipv6_cidr_blocks = [aws_vpc.vpc_terraform.ipv6_cidr_block]
  }

  ingress {
    description = "80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.vpc_terraform.ipv6_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow traffic"
  }
}

#Criando instancia

resource "aws_instance" "web" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t3a.small"
  # key_name               = var.key_name
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.webserver.id]

  associate_public_ip_address = true

  #userdata
  user_data = <<EOF
 #!/bin/bash
 apt-get -y update
 apt-get -y install nginx
 service nginx start
 echo fin v1.00!
 EOF

  tags = {
    Name = "CloudAcademy"
  }
}
