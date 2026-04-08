output "ec2_public_ip" {
  value = aws_instance.my_public_ec2.public_ip
}

output "ec2_private_ip" {
  value = aws_instance.my_private_ec2.public_ip
}

output "ssh_user" {
  value = "ec2-user"
}

output "alb_dns_name" {
  value = aws_lb.front.dns_name
}