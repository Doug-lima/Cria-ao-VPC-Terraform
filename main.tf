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
  availability_zone = var.availability_zones[0] # Variable declared in variables.tfvars 

  tags = {
    Name = "Subnet2"
    Type = "Public"
  }
}

# Configuring internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_terraform.id

  tags = {
    Name      = "GW VPC SUBNET1 TERRAFORM"
    Owner     = "Douglas"
    CreatedAt = "2023-02-23"
  }
}

## PAREI NA CRIAÇÃO DO ROUTE_TABLE