resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for iTop EC2 instance"
  vpc_id      = var.vpc_id

  # HTTP ingress
  ingress {
    from_port   = var.ec2_http_port
    to_port     = var.ec2_http_port
    protocol    = var.ec2_http_protocol
    cidr_blocks = var.ec2_http_cidr_blocks
  }

  # Optional SSH ingress
  dynamic "ingress" {
    for_each = var.enable_ssh ? [1] : []
    content {
      from_port   = var.ec2_ssh_port
      to_port     = var.ec2_ssh_port
      protocol    = var.ec2_ssh_protocol
      cidr_blocks = var.ec2_ssh_cidr_blocks
    }
  }

  # Outbound: allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for iTop RDS instance"
  vpc_id      = var.vpc_id

  # Only allow MySQL from EC2 SG
  ingress {
    from_port       = var.rds_port
    to_port         = var.rds_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  # Outbound: allow all (for updates, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}
