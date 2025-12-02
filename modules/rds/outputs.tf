output "endpoint" {
  value = aws_db_instance.this.address
}

output "identifier" {
  value = aws_db_instance.this.id
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.this.id
}