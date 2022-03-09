provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIASS4Z33TDGNFYO7WK"
  secret_key = "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"
}
resource "aws_vpc" "main" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}
resource "aws_subnet" "pub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "public"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "IGW"
  }
}
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "custom"
  }
}
resource "aws_route_table_association" "as1" {
  subnet_id      = aws_subnet.pub.id
  route_table_id = aws_route_table.rt1.id
}
resource "aws_security_group" "allow_SG" {
  name        = "firstSG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

