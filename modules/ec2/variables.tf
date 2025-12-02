variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "associate_public_ip" {
  type = bool
}

variable "key_name" {
  type = string
}

variable "root_volume_size_gb" {
  type = number
}

variable "itop_web_root" {
  type = string
}