output "ec2_public_ip" {
  value = aws_instance.my_ec2.public_ip
}

output "ssh_user" {
  value = "ec2-user"
}

output "private_key_path"{
  value = aws_key_pair.my_key.key_name
}