resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_name

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    itop_web_root = var.itop_web_root
  }))

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