output "ec2_public_ip" {
  value = aws_instance.my_ec2.public_ip
}

output "shh_user" {
  value = "ec2-user"
}