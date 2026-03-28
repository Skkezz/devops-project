terraform {
  backend "s3" {
    bucket = "matija-devops-terraform-state-bucket"
    key    = "my-basic-app/terraform.tfstate"
    region = "eu-central-1"
  }
}
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "my-basic-vpc"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.vpc_subnet_public_cidr
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name = var.vpc_subnet_public_name
  }
}

resource "aws_eip" "my_elastic_ip"{
  domain = "vpc"

  tags = {
    Name = "my-basic-elastic-ip"
  }
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.vpc_subnet_private_cidr
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1a"

  tags = {
    Name = var.vpc_subnet_private_name
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.ig_name
  }
}

resource "aws_nat_gateway" "gw"{
  allocation_id = aws_eip.my_elastic_ip.id
  subnet_id = aws_subnet.my_public_subnet.id

  tags = {
    Name = "Basic NAT gateway"
  }
  depends_on = [aws_internet_gateway.my_igw.id]  
}

resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.route_public_table_name
  }
}

resource "aws_route_table" "my_private_rt"{
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.route_private_table_name
  }
}

resource "aws_route" "my_public_route" {
  route_table_id         = aws_route_table.my_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route" "my_nat_route"{
  route_table_id = aws_route_table.my_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gw.id
}

resource "aws_route_table_association" "my_public_assoc" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_public_rt.id
}

resource "aws_route_table_association" "my_private_assoc"{
  subnet_id = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_rt.id
}

resource "aws_security_group" "my_security_group" {
  name        = "my-basic-public-sg"
  description = "my basic public security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Moja ip adresa
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Moja ip adresa
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Block key-pair za public ec2 ###
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "my_public_ec2" {
  ami           = var.ec2_public_ami
  instance_type = var.ec2_public_type

  subnet_id                   = aws_subnet.my_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.TF-public-key.key_name

  user_data = templatefile("${path.module}/user_data.tftpl", {
    creator = "Matija"
  })
  tags = {
    Name = var.ec2_public_name
  }
}

### Block za private ec2

resource "aws_security_group" "my_security_group"{
  name        = "my-basic-private-sg"
  description = "my basic private security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_instance.my_ec2.public_ip] // Public EC2 address
  }  
}

resource "aws_instance" "my_private_ec2"{
  ami           = var.ec2_private_ami
  instance_type = var.ec2_private_type

  subnet_id = aws_subnet.my_private_subnet.id
  associate_public_ip_address = false
  

  tags = {
    Name = var.ec2_private_name
  }
}