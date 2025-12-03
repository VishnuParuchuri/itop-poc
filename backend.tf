terraform {
  backend "s3" {
    key    = "itop-poc/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
  }
}