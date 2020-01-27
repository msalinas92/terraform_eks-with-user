provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

