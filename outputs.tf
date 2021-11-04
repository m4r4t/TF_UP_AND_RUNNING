output "pub_ip" {
 value = aws_instance.ec2_example_instance.public_ip 
}

output "ec2_arn" {
    value = aws_instance.ec2_example_instance.arn
}