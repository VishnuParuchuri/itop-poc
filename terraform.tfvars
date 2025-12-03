aws_region        = "ap-south-1"
environment       = "poc"
project_name      = "itop-poc"

# EC2 Configuration
ec2_ami_id               = "ami-0d176f79571d18a8f"  # Amazon Linux 2023 ap-south-1
ec2_instance_type        = "t3.small"
ec2_root_volume_size     = 20
ec2_associate_public_ip  = true
ec2_key_name            = "itop-poc-poc-key"
ec2_subnet_index        = 0
itop_web_root           = "/var/www/html"
itop_web_path           = "itop"

# Security Group - HTTP
ec2_http_port           = 80
ec2_http_protocol       = "tcp"
ec2_http_cidr_blocks    = ["0.0.0.0/0"]

# Security Group - SSH
enable_ssh              = true
ec2_ssh_port           = 22
ec2_ssh_protocol       = "tcp"
ec2_ssh_cidr_blocks    = ["0.0.0.0/0"]

# RDS Configuration
rds_allocated_storage       = 20
rds_engine                 = "mysql"
rds_engine_version         = "8.0"
rds_instance_class         = "db.t3.micro"
rds_db_name               = "itopdb"
rds_username              = "itopuser"
# rds_password will be provided by Jenkins via TF_VAR_rds_password credential
rds_port                  = 3306
rds_multi_az              = false
rds_publicly_accessible   = false
rds_backup_retention_period = 1
rds_deletion_protection    = false
rds_skip_final_snapshot    = true