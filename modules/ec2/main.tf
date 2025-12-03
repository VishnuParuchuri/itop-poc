# Generate a private key
resource "tls_private_key" "itop_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "itop_key_pair" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = tls_private_key.itop_key.public_key_openssh

  tags = {
    Name        = "${var.project_name}-${var.environment}-key"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Save private key to local file
resource "local_file" "private_key" {
  content  = tls_private_key.itop_key.private_key_pem
  filename = "${path.root}/itop-poc-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  associate_public_ip_address = var.associate_public_ip
  key_name                    = aws_key_pair.itop_key_pair.key_name

  # Minimal user_data – just a marker log so instance boots cleanly
  user_data = <<-EOF
              #!/bin/bash
              echo "iTop EC2 instance booted at $(date)" > /var/log/itop-bootstrap.log
              EOF

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-itop-ec2"
    Project     = var.project_name
    Environment = var.environment
  }
}