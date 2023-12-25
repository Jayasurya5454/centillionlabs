provider "aws" {
  region = "ap-south-1" 
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24" 
  availability_zone       = "ap-south-1b"

  tags = {
    Name = "Private Subnet"
  }
}


resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example.id
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
}

resource "aws_security_group" "bastion_host" {
  name_prefix = "bastion-host-sg-"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 
}

resource "aws_instance" "bastion_host" {
  ami                    = "ami-0e159fc62d940d348"  
  instance_type          = "t2.micro"
  key_name               = "jayasuryakeypair"
  vpc_security_group_ids = [aws_security_group.bastion_host.id]
  subnet_id              = aws_subnet.public.id
}

resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0e159fc62d940d348"  
  instance_type          = "t2.micro"
  key_name               = "jayasuryakeypair"
  vpc_security_group_ids = [aws_security_group.bastion_host.id]
  subnet_id              = aws_subnet.private.id
}

resource "aws_security_group_rule" "bastion_host_ingress_ssh" {
  type              = "ingress"
  from_port         = 2222
  to_port           = 2222 
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_host.id
}

resource "aws_security_group_rule" "bastion_host_ingress_rdp" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_host.id
}