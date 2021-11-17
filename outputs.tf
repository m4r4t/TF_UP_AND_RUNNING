output "pub_ip" {
  value = aws_instance.ec2-public-access.public_ip
}

output "ec2_arn" {
  value = aws_instance.ec2-public-access.arn
}

output "db_priv_ip" {
  value = aws_instance.ec2-private-access.private_ip
}