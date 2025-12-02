# Common / global
variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

# EC2 related
variable "ec2_ami_id" {
  type = string
}

variable "ec2_instance_type" {
  type = string
}

variable "ec2_root_volume_size" {
  type = number
}

variable "ec2_associate_public_ip" {
  type = bool
}

variable "ec2_key_name" {
  type = string
}

variable "ec2_subnet_index" {
  type = number
}

variable "itop_web_root" {
  type = string
}

variable "itop_web_path" {
  type = string
}

# HTTP security group inputs
variable "ec2_http_port" {
  type = number
}

variable "ec2_http_protocol" {
  type = string
}

variable "ec2_http_cidr_blocks" {
  type = list(string)
}

# SSH security group inputs
variable "enable_ssh" {
  type = bool
}

variable "ec2_ssh_port" {
  type = number
}

variable "ec2_ssh_protocol" {
  type = string
}

variable "ec2_ssh_cidr_blocks" {
  type = list(string)
}

# RDS inputs
variable "rds_allocated_storage" {
  type = number
}

variable "rds_engine" {
  type = string
}

variable "rds_engine_version" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "rds_db_name" {
  type = string
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "rds_port" {
  type = number
}

variable "rds_multi_az" {
  type = bool
}

variable "rds_publicly_accessible" {
  type = bool
}

variable "rds_backup_retention_period" {
  type = number
}

variable "rds_deletion_protection" {
  type = bool
}

variable "rds_skip_final_snapshot" {
  type = bool
}
