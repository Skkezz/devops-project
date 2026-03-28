variable "vpc_cidr" {
  description = "Value of the CIDR range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Value of the Name for the VPC"
  type        = string
  default     = "my-basic-vpc"
}

variable "vpc_subnet_public_name" {
  description = "Value of the Name for the public subnet"
  type        = string
  default     = "public_subnet"
}

variable "vpc_subnet_public_cidr" {
  description = "Value of the CIDR range for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "vpc_subnet_private_name" {
  type        = string
  default     = "Value of the Name for the private subnet"
  description = "private_subnet"
}

variable "vpc_subnet_private_cidr" {
  type        = string
  default     = "Value of the CIDR range for the private subnet"
  description = "10.0.1.0/24"
}


variable "ec2_public_name" {
  description = "Value of the Name for the public EC2 instance"
  type        = string
  default     = "my-public-basic-ec2"
}

variable "ec2_public_ami" {
  description = "Value of the AMI ID for the public EC2 instance"
  type        = string
  default     = "ami-096a4fdbcf530d8e0" #Amazon Linux 
}

variable "ec2_public_type" {
  description = "Value of the instance type for the public EC2"
  type        = string
  default     = "t3.micro"
}

variable ec2_private_name {
  description = "Value of the Name for the private EC2 instance"
  type        = string
  default     = "my-private-basic-ec2"
}

variable "ec2_private_ami" {
  description = "Value of the AMI ID for the private EC2 instance"
  type        = string
  default     = "ami-096a4fdbcf530d8e0" #Amazon Linux 
}

variable "ec2_private_type" {
  description = "Value of the instance type for the private EC2"
  type        = string
  default     = "t3.micro"
}


variable "ig_name" {
  description = "Value of the Name for the internet gateway"
  type        = string
  default     = "my-basic-igw"
}

variable "route_public_table_name" {
  description = "Value of the Name for the public route table"
  type        = string
  default     = "my-basic-public-rt"
}

variable "route_private_table_name"{
  description = "Value of the Name for the private route table"
  type = string
  default = "my-basic-private-rt"
}
