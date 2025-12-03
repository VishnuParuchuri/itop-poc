output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.web.public_ip
}

output "private_ip" {
  description = "EC2 instance private IP"
  value       = aws_instance.web.private_ip
}

output "key_pair_name" {
  description = "Name of the generated key pair"
  value       = aws_key_pair.itop_key_pair.key_name
}

output "private_key_file" {
  description = "Path to the private key file"
  value       = "${path.root}/itop-poc-key.pem"
}