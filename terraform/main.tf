terraform {
  backend "s3" {
    bucket  = "matija-devops-terraform-state-bucket"
    key     = "my-basic-app/terraform.tfstate"
    region  = "eu-central-1"
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

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

resource "aws_subnet" "my_public2_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"

  tags = {
    Name = "my-second-public-subnet"
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

resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.route_public_table_name
  }
}

resource "aws_route_table" "my_private_rt" {
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



resource "aws_route_table_association" "my_public_assoc" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_public_rt.id
}

resource "aws_route_table_association" "my_private_assoc" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_rt.id
}

resource "aws_security_group" "my_security_public_group" {
  name        = "my-basic-public-sg"
  description = "my basic public security group"
  vpc_id      = aws_vpc.my_vpc.id


  ingress {
    from_port   = 22
    to_port     = 22
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
  vpc_security_group_ids      = [aws_security_group.my_security_public_group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.TF-public-key.key_name

  iam_instance_profile = "s3-access-policy"

  user_data = templatefile("${path.module}/user_data.tftpl", {
    creator = "Matija"
  })
  tags = {
    Name = var.ec2_public_name
  }
}

### Block za private ec2 

resource "aws_security_group" "my_security_private_group" {
  name        = "my-basic-private-sg"
  description = "my basic private security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name   = "vpc-endpoint-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.my_security_private_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.my_vpc.id
  service_name      = "com.amazonaws.eu-central-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.my_private_rt.id]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.my_vpc.id
  service_name        = "com.amazonaws.eu-central-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.my_private_subnet.id]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.my_vpc.id
  service_name        = "com.amazonaws.eu-central-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.my_private_subnet.id]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.my_vpc.id
  service_name        = "com.amazonaws.eu-central-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.my_private_subnet.id]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
}

resource "aws_instance" "my_private_ec2" {
  ami           = var.ec2_private_ami
  instance_type = var.ec2_private_type

  subnet_id                   = aws_subnet.my_private_subnet.id
  iam_instance_profile        = "ec2-ssm-role"
  associate_public_ip_address = false

  vpc_security_group_ids = [aws_security_group.my_security_private_group.id]

  user_data = templatefile("${path.module}/user_data_private.tftpl", {
    creator = "Matija"
  })
  tags = {
    Name = var.ec2_private_name
  }
}