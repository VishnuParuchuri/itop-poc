variable "vpc_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

# HTTP
variable "ec2_http_port" {
  type = number
}

variable "ec2_http_protocol" {
  type = string
}

variable "ec2_http_cidr_blocks" {
  type = list(string)
}

# SSH
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

# RDS
variable "rds_port" {
  type = number
}
