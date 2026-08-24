# Config

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# Instances

resource "aws_instance" "Admin" {
  ami                    = "ami-07ba4be829b9bf20a"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.admin.id]
  key_name = aws_key_pair.admin.key_name

  tags = {
    Name = "linux-admin"
  }
}

resource "aws_instance" "RHEL" {
  ami                    = "ami-07ba4be829b9bf20a"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.targets.id]
  key_name = aws_key_pair.rhel.key_name

  tags = {
    Name = "rhel-target"
  }
}

resource "aws_instance" "Debian" {
  ami                    = "ami-01ef747f983799d6f"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.targets.id]
  key_name = aws_key_pair.debian.key_name

  tags = {
    Name = "debian-target"
  }
}

# keys

resource "aws_key_pair" "admin" {
  key_name   = "linux-admin-key"
  public_key = file("./EC2s_public_keys/linux-admin.pub")
}

resource "aws_key_pair" "debian" {
  key_name   = "debian-key"
  public_key = file("./EC2s_public_keys/debian.pub")
}

resource "aws_key_pair" "rhel" {
  key_name   = "rhel-key"
  public_key = file("./EC2s_public_keys/rhel.pub")
}
# Network

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "linux-admin-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "linux-admin-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_eip" "admin" {
  domain = "vpc"

  tags = {
    Name = "linux-admin-eip"
  }
}

resource "aws_eip_association" "admin" {
  instance_id = aws_instance.Admin.id
  allocation_id = aws_eip.admin.id
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main.id

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name = "private-subnet-nat"
  }
}

resource "aws_route_table" "private_nat" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_nat.id
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private_nat.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Security Groups

resource "aws_security_group" "admin" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH from my PC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "admin-sg"
  }
}

resource "aws_security_group" "targets" {
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "SSH from Admin"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.admin.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "targets-sg"
  }
}