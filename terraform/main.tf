resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "my-basic-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.vpc_subnet_public_cidr
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name = var.vpc_subnet_public_name
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.ig_name
  }
}

resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route" "my_public_route" {
  route_table_id         = aws_route_table.my_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "my_public_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_public_rt.id
}

resource "aws_security_group" "my_security_group" {
  name        = "my-basic-sg"
  description = "my basic security group"
  vpc_id      = aws_vpc.my_vpc.id

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
}

resource "tls_private_key" "RSA" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
  content  = tls_private_key.RSA.private_key_pem
  filename = "my-basic-private-key"
}

resource "aws_key_pair" "TF-public-key" {
  key_name   = "my-basic-key"
  public_key = tls_private_key.RSA.public_key_openssh
}

resource "aws_instance" "my_ec2" {
  ami           = var.ec2_ami
  instance_type = var.ec2_type

  subnet_id                   = aws_subnet.my_subnet.id
  vpc_security_group_ids      = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.TF-public-key.key_name

  tags = {
    Name = var.ec2_public_name
  }
}