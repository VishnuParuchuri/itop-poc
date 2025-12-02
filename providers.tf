provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "itop-poc"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}