output "ec2_public_ip" {
  description = "Public IP of the iTop EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "rds_endpoint" {
  description = "RDS endpoint for MySQL"
  value       = module.rds.endpoint
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = module.rds.identifier
}

output "itop_url" {
  description = "URL to access iTop"
  value       = "http://${module.ec2.public_ip}/itop"
}


output "db_instance_id" {
  description = "RDS instance ID"
  value       = module.rds.db_instance_id
}

output "key_pair_name" {
  description = "Name of the generated key pair"
  value       = module.ec2.key_pair_name
}

output "private_key_file" {
  description = "Path to the private key file"
  value       = module.ec2.private_key_file
}