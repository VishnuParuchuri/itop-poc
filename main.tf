# Use default VPC (as per assumption)
data "aws_vpc" "default" {
  default = true
}

# Get all subnets in default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -------------------------
# Security Groups module
# -------------------------
module "security" {
  source = "./modules/security_group"

  vpc_id       = data.aws_vpc.default.id
  project_name = var.project_name
  environment  = var.environment

  # HTTP
  ec2_http_port        = var.ec2_http_port
  ec2_http_protocol    = var.ec2_http_protocol
  ec2_http_cidr_blocks = var.ec2_http_cidr_blocks

  # SSH (optional)
  enable_ssh          = var.enable_ssh
  ec2_ssh_port        = var.ec2_ssh_port
  ec2_ssh_protocol    = var.ec2_ssh_protocol
  ec2_ssh_cidr_blocks = var.ec2_ssh_cidr_blocks

  # RDS
  rds_port = var.rds_port
}

# -------------------------
# RDS module
# -------------------------
module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  environment  = var.environment

  subnet_ids        = data.aws_subnets.default.ids
  security_group_id = module.security.rds_sg_id

  allocated_storage       = var.rds_allocated_storage
  engine                  = var.rds_engine
  engine_version          = var.rds_engine_version
  instance_class          = var.rds_instance_class
  db_name                 = var.rds_db_name
  username                = var.rds_username
  password                = var.rds_password
  port                    = var.rds_port
  multi_az                = var.rds_multi_az
  publicly_accessible     = var.rds_publicly_accessible
  backup_retention_period = var.rds_backup_retention_period
  deletion_protection     = var.rds_deletion_protection
  skip_final_snapshot     = var.rds_skip_final_snapshot
}

# -------------------------
# EC2 module
# -------------------------
module "ec2" {
  source = "./modules/ec2"

  project_name = var.project_name
  environment  = var.environment

  ami_id              = var.ec2_ami_id
  instance_type       = var.ec2_instance_type
  subnet_id           = data.aws_subnets.default.ids[var.ec2_subnet_index]
  security_group_id   = module.security.ec2_sg_id
  associate_public_ip = var.ec2_associate_public_ip
  key_name            = var.ec2_key_name
  root_volume_size_gb = var.ec2_root_volume_size
  itop_web_root       = var.itop_web_root
}