# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
/* resource "aws_instance" "pace" {
  ami           = "ami-08e4e35cccc6189f4" # us-east-1
  instance_type = "t2.micro"
} */
### VPC
resource "aws_vpc" "pacevpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "pace"
  }
}
### IGW
resource "aws_internet_gateway" "paceigw" {
  vpc_id = aws_vpc.pacevpc.id

  tags = {
    Name = "pace"
  }
}
### subnet
resource "aws_subnet" "pacesubnet" {
  vpc_id     = aws_vpc.pacevpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "pace"
  }
}
### route table
resource "aws_route_table" "paceroutetable" {
  vpc_id = aws_vpc.pacevpc.id

  route =[]

  tags = {
    Name = "pace"
  }
}

### Route
resource "aws_route" "paceroute" {
  route_table_id            = aws_route_table.paceroutetable.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id= aws_internet_gateway.paceigw.id 
  #vpc_peering_connection_id = "pcx-45ff3dc1"
  depends_on                = [aws_route_table.paceroutetable]
}

### SG
resource "aws_security_group" "pacesecgrp" {
  name        = "allow_all_traffic"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.pacevpc.id
  ingress {
    description      = "All Traffic"
    from_port        = 0 #All ports
    to_port          = 0 #All ports
    protocol         = "-1" # All Traffic
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "pace"
  }
}
### rt-association
resource "aws_route_table_association" "pacertassociation" {
  subnet_id      = aws_subnet.pacesubnet.id
  route_table_id = aws_route_table.paceroutetable.id
}
## Ec2
resource "aws_instance" "paceec2" {
  ami           = "ami-08e4e35cccc6189f4" # us-east-1
  instance_type = "t2.micro"
  subnet_id=aws_subnet.pacesubnet.id
   tags = {
    Name = "pace"
  } 
} 